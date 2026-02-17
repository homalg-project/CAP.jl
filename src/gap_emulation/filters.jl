struct Filter <: Function
	name::String
	abstract_type::Type
	concrete_type::Type
	subtypable::Bool
	additional_predicate::Function
	implied_filters::Set{Function}
	implied_properties::Set{Function}
end

# Add a better show method for filters (emulating GAP's view method)
function Base.show(io::IO, filter::Filter)
	print(io, "<Filter \"$(filter.name)\">")
end

function Base.show(io::IO, ::MIME"text/plain", filter::Filter)
	print(io, "<Filter \"$(filter.name)\">")
end

function Filter(name::String, abstract_type::Type)
	Filter(name, abstract_type, obj -> true)
end

function Filter(name::String, abstract_type::Type, additional_predicate::Function)
	Filter(name, abstract_type, Any, true, additional_predicate, Set{Function}(), Set{Function}())
end

function (filter::Filter)(obj)
	if isa(obj, filter.abstract_type)
		return filter.additional_predicate(obj)
	end
	
	filter_obj = FilterOfObject(obj)
	
	if filter_obj === nothing
		return false
	end
	
  if (filter in filter_obj.implied_filters) || (filter_obj in filter.implied_filters)
		return filter.additional_predicate(obj)
	end
	
	if !isempty(filter.implied_properties)
		base_filter = FilterOfType(supertype(filter.abstract_type))
		if base_filter in filter_obj.implied_filters
			return filter.additional_predicate(obj)
		end
	end
	
	return false
end

function IsFilter( obj )
	obj isa Filter
end

# Get the filter associated with a type by deriving filter name from type name
function FilterOfType(T::Type)
	# Walk up the type hierarchy to find a filter
	current_type = T
	while current_type != Any
		# Get the base type name (without parameters)
		
		type_name = (current_type isa UnionAll) ? string(current_type) : string(Base.typename(current_type).name)
		
		# Check if this looks like a filter type marker.
	# Concrete types are named like TheJuliaConcreteType<FilterName>.
	# Abstract types are named like TheJuliaAbstractType<FilterName>.
		if startswith(type_name, "TheJuliaConcreteType") || startswith(type_name, "TheJuliaAbstractType")
			# Extract filter name by removing the prefix (20 chars)
			filter_name = type_name[21:end]
			
			filter_symbol = Symbol(filter_name)
			
			# Get the module where the type was defined
			type_module = Base.typename(current_type).module
			
			# Search in the type's module first, then Main and ModulesForEvaluationStack
			search_modules = unique([type_module, Main, ModulesForEvaluationStack...])
			
			for mod in search_modules
				if isdefined(mod, filter_symbol)
					candidate = getfield(mod, filter_symbol)
					if IsFilter(candidate)
						return candidate
					end
				end
			end
		end
		
		# Move to supertype
		current_type = supertype(current_type)
	end
	
	return nothing
end

# Get the filter associated with an object
function FilterOfObject(obj)
	FilterOfType(typeof(obj))
end

function CategoriesOfObject(obj)
	filter = FilterOfObject(obj)
	if filter === nothing
		return Filter[]
	end
	filters = [filter]
	append!(filters, collect(filter.implied_filters))
	return filters
end

export FilterOfType, FilterOfObject, CategoriesOfObject

macro DeclareFilter(name::String, parent_filter::Union{Symbol,Expr} = :IsObject)
	filter_symbol = Symbol(name)
	abstract_type_symbol = Symbol("TheJuliaAbstractType", name)
	concrete_type_symbol = Symbol("TheJuliaConcreteType", name)
	
	# Check if parent_filter is a FilterIntersection expression
	if parent_filter isa Expr && parent_filter.head == :call && parent_filter.args[1] == :FilterIntersection
		
		args = parent_filter.args[2:end]
		
		length(args) < 2 && error("@DeclareFilter: Filter intersection must have at least two arguments")
		all(a -> a isa Symbol, args) || error("@DeclareFilter: all arguments must be symbol names")
		
		intersection_name = Symbol(join(string.(args), "_and_"))
		
		# Create the intersection filter using the unified @FilterIntersection
		return esc(quote
			if !@isdefined($intersection_name)
				@FilterIntersection $(args...)
			end
			
			# Now declare the actual filter
			local parent = $intersection_name
			@assert parent.subtypable
			abstract type $abstract_type_symbol <: parent.abstract_type end
			struct $concrete_type_symbol{T} <: $abstract_type_symbol
				dict::Dict{Symbol, Any}
			end
			global const $filter_symbol = Filter($name, $abstract_type_symbol, $concrete_type_symbol, true, obj -> parent.additional_predicate(obj), union(Set([parent]), parent.implied_filters), parent.implied_properties)
			nothing # suppress output when using the macro in tests
		end)
	end
	
	additional_predicate = :(obj -> $parent_filter.additional_predicate(obj))
	implied_filters = :(union(Set([$parent_filter]), $parent_filter.implied_filters))
	
	# all our macros are meant to fully execute in the context where the macro is called -> always fully escape them
	esc(quote
		local parent = $parent_filter
		@assert parent.subtypable
		abstract type $abstract_type_symbol <: parent.abstract_type end
		struct $concrete_type_symbol{T} <: $abstract_type_symbol
			dict::Dict{Symbol, Any}
		end
		global const $filter_symbol = Filter($name, $abstract_type_symbol, $concrete_type_symbol, true, $additional_predicate, $implied_filters, Set{Function}())
		nothing # suppress output when using the macro in tests
	end)
end

export @DeclareFilter

function NewFilter( name, parent_filter )
	if !parent_filter.subtypable
		throw("cannot create NewFilter with a parent filter which was itself created by NewFilter")
	end
	type_symbol = Symbol(name, gensym())
	concrete_type = parent_filter.concrete_type{type_symbol}
	additional_predicate = parent_filter.additional_predicate
	implied_filters = union(Set([parent_filter]), parent_filter.implied_filters)
	implied_properties = parent_filter.implied_properties
	Filter(name, concrete_type, concrete_type, false, parent_filter.additional_predicate, implied_filters, implied_properties)
end

global const NewCategory = NewFilter
