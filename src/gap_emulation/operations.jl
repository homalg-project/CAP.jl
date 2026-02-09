## macros

const GLOBAL_COUNTER = Ref(0)

function next_id()
    GLOBAL_COUNTER[] += 1
end

# --- Shared helpers for method installation macros ---

"""Check if the operation should be skipped (ViewObj, Display, Iterator)."""
function should_skip_operation(operation::Symbol)
	if operation === :ViewObj
		println("ignoring installation for ViewObj, use ViewString instead")
		return true
	elseif operation === :Display
		println("ignoring installation for Display, use DisplayString instead")
		return true
	elseif operation === :Iterator
		println("ignoring installation for Iterator, install iterator in Julia instead")
		return true
	end
	return false
end

"""Normalize a function expression (symbol, lambda, macrocall) into a `:function` form."""
function normalize_func_to_function_expr(func, filter_count::Int, mod::Module)
	if !(func isa Expr)
		if filter_count == 0
			func = :((args...) -> $func(args...))
		else
			vars = Vector{Any}(map(i -> Symbol("arg", i), 1:filter_count))
			func = :(($(vars...),) -> $func($(vars...),))
		end
	end
	
	if func.head === :macrocall
		func = macroexpand(mod, func; recursive = false)
	end
	
	if func.head === :->  
		func.head = :function
		if func.args[1] isa Symbol
			func.args[1] = Expr(:tuple, func.args[1])
		end
	end
	
	@assert func.head === :function "Expected :function expression, got :$(func.head)"
	return func
end

"""Set the callable (self-argument) in a function expression."""
function set_func_callable!(func::Expr, callable::Expr, filter_list)
	if func.args[1].head === :tuple
		func.args[1] = Expr(:call, callable, func.args[1].args...)
	elseif func.args[1].head === :...
		@assert filter_list === :nothing
		func.args[1] = Expr(:call, callable, func.args[1])
	else
		error("unsupported head: ", func.args[1].head)
	end
end

"""Check if a function expression has keyword arguments."""
func_has_kwargs(func::Expr) = length(func.args[1].args) >= 2 && func.args[1].args[2] isa Expr && func.args[1].args[2].head === :parameters

# --- End shared helpers ---

macro DeclareOperation(name::String, filter_list = [])
	# prevent attributes from being redefined as operations
	if isdefined(__module__, Symbol(name))
		return nothing
	end
	symbol = Symbol(name)
	esc(quote
		function $symbol end
		nothing # suppress output when using the macro in tests
	end)
end

export @DeclareOperation

macro KeyDependentOperation(name::String, filter1, filter2, func)
	symbol = Symbol(name)
	symbol_op = Symbol(name * "Op")
	esc(quote
		@DeclareOperation($name)
		global const $symbol_op = $symbol
		nothing # suppress output when using the macro in tests
	end)
end

export @KeyDependentOperation

macro InstallMethod(operation::Symbol, description::String, filter_list, func)
	esc(:(@InstallMethod($operation, $filter_list, $func)))
end

function get_operation_for_installation(operation, filter_list)
	if IsAttribute(operation)
		@assert filter_list !== :nothing
		
		attr = operation
		
		if length(filter_list) === 1 && filter_list[1].abstract_type <: IsAttributeStoringRep.abstract_type
			return attr.operation
		end
	end
	
	return operation
end

macro InstallMethod(operation::Symbol, filter_list, func)
	
	should_skip_operation(operation) && return
	
	# Delegate to @InstallFilterDispatchedMethod if the operation is declared as dispatchable
	if isdefined(__module__, operation)
		op_val = getfield(__module__, operation)
		if is_dispatchable(op_val)
			return esc(:(@InstallFilterDispatchedMethod($operation, $filter_list, $func)))
		end
	end
	
	@assert (filter_list === :nothing || (filter_list isa Expr && filter_list.head === :vect && all(f -> f isa Symbol, filter_list.args))) "Assertion failed while installing $(operation) with the filter_list: $(filter_list)"
	
	filter_count = filter_list === :nothing ? 0 : length(filter_list.args)
	func = normalize_func_to_function_expr(func, filter_count, __module__)
	
	callable = :(::typeof(get_operation_for_installation($operation, $filter_list)))
	set_func_callable!(func, callable, filter_list)
	
	is_kwarg = func_has_kwargs(func)
	
	if filter_list !== :nothing
		if is_kwarg
			offset = 2
		else
			offset = 1
		end
		
		types = map(x -> Expr(:., x, :(:abstract_type)), filter_list.args)
		
		@assert length(filter_list.args) == length(func.args[1].args) - offset
		for i in 1:length(filter_list.args)
			func.args[1].args[i + offset] = Expr(:(::), func.args[1].args[i + offset], types[i])
			# specialize native types (e.g. vectors) for performance
			if !(ValueGlobal( string(filter_list.args[i]) ).abstract_type <: IsAttributeStoringRep.abstract_type)
				func.args[1].args[i + offset] = Expr(:macrocall, Symbol("@specialize"), __source__, func.args[1].args[i + offset])
			end
		end
	end
	
	block = quote
		$func
		nothing # suppress output when using the macro in tests
	end
	
	if filter_list !== :nothing
		push!(block.args, :(CAP_precompile(get_operation_for_installation($operation, $filter_list), ($(types...),))))
	end
	
	esc(block)
end

export @InstallMethod

## runtime

function DeclareOperation(name::String, filter_list = [])
	DeclareOperation(last(ModulesForEvaluationStack), name, filter_list)
	return nothing
end

function DeclareOperation(mod::Module, name::String, filter_list = [])
	# operations can be redeclared with different filters
	if isdefined(mod, Symbol(name))
		return nothing
	end
	NewOperation(mod, name, filter_list)
	return nothing
end

function NewOperation(name::String, filter_list = [])
	NewOperation(last(ModulesForEvaluationStack), name, filter_list)
end

function NewOperation(mod::Module, name::String, filter_list)
	operation = Symbol(name)
	if isdefined(mod, operation)
		while true
			operation = Symbol(name * "#ID:" * string(next_id()))
			if !isdefined(mod, operation)
				break;
			end
		end
	end
	Base.eval(mod, quote
		function $operation end
		export $operation
		$operation # return value
	end)
end

function InstallMethod(operation, filter_list, func)
	InstallMethod(last(ModulesForEvaluationStack), operation, filter_list, func)
end

function InstallMethod(mod::Module, operation::Function, filter_list, func::Function)
	
	if operation === ViewObj
		println("ignoring installation for ViewObj, use ViewString instead")
		return
	elseif operation === Display
		println("ignoring installation for Display, use DisplayString instead")
		return
	elseif operation === Iterator
		println("ignoring installation for Iterator, install iterate in Julia instead")
		return
	end
	
	nargs = length(filter_list)
	vars = Vector{Any}(map(i -> Symbol("arg", i), 1:nargs))
	types = [filter.abstract_type for filter in filter_list]
	vars_with_types = map(function(i)
		arg_symbol = vars[i]
		type = types[i]
		:($arg_symbol::$type)
	end, 1:length(filter_list))
	if IsAttribute( operation )
		if length(filter_list) === 1 && filter_list[1].abstract_type <: IsAttributeStoringRep.abstract_type
			funcref = Symbol(operation.operation)
			operation_to_precompile = operation.operation
		else
			funcref = :(::typeof($(Symbol(operation.name))))
			operation_to_precompile = operation
		end
	else
		funcref = Symbol(operation)
		operation_to_precompile = operation
	end
	
	if funcref isa Symbol && !isdefined(mod, funcref)
		print("WARNING: installing method in module ", mod, " for undefined symbol ", funcref, "\n")
	end
	
	for i in 1:length(types)
		# specialize native types (e.g. vectors) for performance
		if !(types[i] <: IsAttributeStoringRep.abstract_type)
			vars_with_types[i] = Expr(:macrocall, Symbol("@specialize"), LineNumberNode(@__LINE__, @__FILE__), vars_with_types[i])
		end
	end
	
	is_kwarg = any(m -> !isempty(Base.kwarg_decl(m)), methods(func))
	
	if is_kwarg
		Base.eval(mod, :(
			function $funcref($(vars_with_types...); kwargs...)
				$func($(vars...); kwargs...)
			end
		))
	else
		Base.eval(mod, :(
			function $funcref($(vars_with_types...))
				$func($(vars...))
			end
		))
	end
	
	CAP_precompile(operation_to_precompile, (types...,))
end

function InstallMethod(operation, description::String, filter_list, func)
	InstallMethod(operation, filter_list, func)
end

function InstallMethod(mod, operation, description::String, filter_list, func)
	InstallMethod(mod, operation, filter_list, func)
end

global const InstallOtherMethod = InstallMethod
function InstallMethodWithCacheFromObject( operation, filter_list, func; ArgumentNumber = 1 )
	InstallMethod( operation, filter_list, func )
end
function InstallMethodWithCache( operation, filter_list, func; InstallMethod = InstallMethod, Cache = "cache" )
	InstallMethod( operation, filter_list, func )
end
function InstallMethodWithCache( operation, description, filter_list, func; InstallMethod = InstallMethod, Cache = "cache" )
	InstallMethod( operation, filter_list, func )
end
global const InstallMethodWithCrispCache = InstallMethod
