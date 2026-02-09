struct FilterDispatchedOperation <: Function
  name::String
end

string(op::FilterDispatchedOperation) = op.name

is_dispatchable(::Any) = false
is_dispatchable(::FilterDispatchedOperation) = true

function (op::FilterDispatchedOperation)(args...)
	method_func = find_filter_method(Symbol(op.name), args...)
	if method_func !== nothing
		return Base.invokelatest(method_func, args...)
	else
		error("No method found for ", op.name, " with the given arguments")
	end
end

const FILTER_DISPATCHED_OPERATIONS_REGISTRY = Dict{Symbol, Vector{Tuple{Vector{Filter}, Function}}}()
const OPERATION_COUNTER = Dict{Symbol, Int}()

function next_operation_id(operation_name::Symbol)
	if !haskey(OPERATION_COUNTER, operation_name)
		OPERATION_COUNTER[operation_name] = 0
	end
	OPERATION_COUNTER[operation_name] += 1
	return OPERATION_COUNTER[operation_name]
end

function register_filter_method(operation_name::Symbol, filter_signature::Vector{Filter}, method_func::Function)
	if !haskey(FILTER_DISPATCHED_OPERATIONS_REGISTRY, operation_name)
		FILTER_DISPATCHED_OPERATIONS_REGISTRY[operation_name] = Tuple{Vector{Filter}, Function}[]
	end
	
	# Add the method
	pushfirst!(FILTER_DISPATCHED_OPERATIONS_REGISTRY[operation_name], (filter_signature, method_func))
	
	# Sort by specificity: more specific signatures first
	# Specificity is determined by the sum of implied filters and properties across all arguments
	sort!(FILTER_DISPATCHED_OPERATIONS_REGISTRY[operation_name],
		by = entry -> sum(f -> length(f.implied_filters) + length(f.implied_properties), entry[1]; init=0),
		rev = true)
	
	return method_func
end

function find_filter_method(operation_name::Symbol, args...)
	if !haskey(FILTER_DISPATCHED_OPERATIONS_REGISTRY, operation_name)
		return nothing
	end
	
	methods = FILTER_DISPATCHED_OPERATIONS_REGISTRY[operation_name]
	
	# Try each method signature in order of specificity (most specific first)
	for (filter_signature, method_func) in methods
		if length(args) != length(filter_signature)
			continue
		end
		
		all_match = true
		for (arg, required_filter) in zip(args, filter_signature)
			if !required_filter(arg)
				all_match = false
				break
			end
		end
		
		if all_match
			return method_func
		end
	end
	
	return nothing
end

macro DeclareFilterDispatchedOperation(operation::String, args...)
	
  operation_symbol = Symbol(operation)
  
	block = quote
		if isdefined(@__MODULE__, $(QuoteNode(operation_symbol)))
			error("Operation ", $(operation), " is already defined. Cannot be declared as filter-dispatched operation.")
		end
		
		global const $(operation_symbol) = CAP.FilterDispatchedOperation($(QuoteNode(operation)))
		
		nothing
	end
	
	esc(block)
end

macro InstallFilterDispatchedMethod(operation::Symbol, filter_list, func)
	should_skip_operation(operation) && return
	
	# Handle FilterIntersection expressions
	local setup_exprs = Any[]
	local filter_list_norm = filter_list
	local base_filter_list = nothing  # Track base filters for intersections
	
	if filter_list !== :nothing
		@assert (filter_list isa Expr && filter_list.head === :vect) "Assertion failed while installing $(operation) with the filter_list: $(filter_list)"

		function normalize_filter_term(term)
			if term isa Symbol
				return (Any[], term, term)  # (setup, normalized_sym, base_filter)
			end
			
			if term isa Expr && term.head === :call && term.args[1] === :FilterIntersection && length(term.args) >= 3
				args = term.args[2:end]
				all_setups = Any[]
				normalized_syms = Symbol[]
				
				for arg in args
					setups, sym, _ = normalize_filter_term(arg)
					append!(all_setups, setups)
					push!(normalized_syms, sym)
				end
				
				intersection_sym = Symbol(join(string.(normalized_syms), "_and_"))
				intersection_sym_qn = QuoteNode(intersection_sym)
				
				setup_intersection = quote
					if !isdefined(@__MODULE__, $intersection_sym_qn)
						CAP.@FilterIntersection $(normalized_syms...)
					end
				end
				
				# Return the first filter as the base filter
				return (Any[all_setups..., setup_intersection], intersection_sym, normalized_syms[1])
			end
			
			error("Unsupported filter term in @InstallFilterDispatchedMethod: $(term)")
		end
		
		norm_args = Any[]
		base_args = Any[]
		for term in filter_list.args
			setups, sym, base = normalize_filter_term(term)
			append!(setup_exprs, setups)
			push!(norm_args, sym)
			push!(base_args, base)
		end
		filter_list_norm = Expr(:vect, norm_args...)
		base_filter_list = Expr(:vect, base_args...)
	end
	
	# Normalize function expression
	filter_count = filter_list_norm === :nothing ? 0 : length(filter_list_norm.args)
	func = normalize_func_to_function_expr(func, filter_count, __module__)
	
	# Generate unique numbered operation name at macro expansion time
	numbered_operation = Symbol(operation, "_METHOD_", next_operation_id(operation))
	
	callable = :(::typeof($numbered_operation))
	set_func_callable!(func, callable, filter_list)
	
	is_kwarg = func_has_kwargs(func)
	
	# Add type annotations - use base filters for actual method installation
	types = []
	if filter_list_norm !== :nothing
		if is_kwarg
			offset = 2
		else
			offset = 1
		end
		
		# Use base_filter_list for actual type annotations on the method
		types = map(x -> Expr(:., x, :(:abstract_type)), base_filter_list.args)
		
		@assert length(base_filter_list.args) == length(func.args[1].args) - offset
		for i in 1:length(base_filter_list.args)
			func.args[1].args[i + offset] = Expr(:(::), func.args[1].args[i + offset], types[i])
			filter_sym = base_filter_list.args[i]
			if isdefined(__module__, filter_sym)
				filter_val = getfield(__module__, filter_sym)
				if IsFilter(filter_val) && !(filter_val.abstract_type <: IsAttributeStoringRep.abstract_type)
					func.args[1].args[i + offset] = Expr(:macrocall, Symbol("@specialize"), __source__, func.args[1].args[i + offset])
				end
			else
				func.args[1].args[i + offset] = Expr(:macrocall, Symbol("@specialize"), __source__, func.args[1].args[i + offset])
			end
		end
	end
	
	# Build the block
	block = quote
		$(setup_exprs...)
		
		# Define numbered operation
		function $numbered_operation end
		
		# Install method
		$func
	end
	
	push!(block.args, quote
			let filter_objs = CAP.Filter[$(filter_list_norm.args...)]
				let actual_op = get_operation_for_installation($operation, filter_objs)
					# Register using the name of the actual operation (for attributes, this will be MyAttribute_OPERATION)
					CAP.register_filter_method(
						Symbol(actual_op.name),
						filter_objs,
						$numbered_operation
					)
				end
			end
		end)
	
	push!(block.args, :nothing)
	
	# Add precompilation
	if filter_list_norm !== :nothing
		push!(block.args, :(CAP_precompile($numbered_operation, ($(types...),))))
	end
	
	esc(block)
end

export @DeclareFilterDispatchedOperation, @InstallFilterDispatchedMethod