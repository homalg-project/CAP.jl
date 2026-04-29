# Unified filter intersection macro - accepts filters and properties in any order
macro FilterIntersection(args...)
	length(args) < 2 && error("@FilterIntersection expects at least two arguments")
	all(arg -> arg isa Symbol, args) || error("@FilterIntersection expects symbol names as arguments")
	
	# Create a predictable name from the macro arguments
	first_filter = args[1]
	joined_name = join(string.(args), "_and_")
	joined_symbol = Symbol(joined_name)
	abstract_type_name = Symbol("TheJuliaAbstractType", joined_name)
	concrete_type_name = Symbol("TheJuliaConcreteType", joined_name)
	# Use gensym to avoid collisions with imported variables from other modules
	result_filter_var = gensym("result_filter")
  
	esc(quote
		# Assert first argument is a filter (will be used as base)
		isa($first_filter, Filter) || error("@FilterIntersection: first argument must be a filter, got: ", $first_filter)
		
		# Define types using first filter as base (known at macro expansion time)
		abstract type $abstract_type_name <: $first_filter.abstract_type end
		struct $concrete_type_name{T} <: $abstract_type_name
			dict::Dict{Symbol, Any}
		end
		
		# Use let block to ensure local scope for variables captured by closure
		# This prevents multiple @FilterIntersection calls from interfering with each other
		$result_filter_var = let
			# Evaluate and classify arguments into filters and properties
			local all_args = [$(args...),]
			local filter_mask = [isa(arg, Filter) for arg in all_args]
			local filters = all_args[filter_mask]
			local properties = all_args[.!filter_mask]
			
			# Validate input
			isempty(filters) && error("@FilterIntersection: At least one filter is required")
			(length(filters) < 2 && isempty(properties)) && error("@FilterIntersection: Need at least 2 filters or 1 filter with properties")
			
			# Use first filter as base, remaining filters and properties form the intersection
			local base_filter = filters[1]
			
			# Build combined name from all components (for potential synonym)
			local combined_name = join([hasproperty(c, :name) ? c.name : string(c) for c in all_args], "_and_")
			
			# Build combined predicate: base + remaining filters + properties
			local additional_predicate = obj -> (
				all(f -> f.additional_predicate(obj), filters) &&
				all(p -> p.tester(obj), properties) &&
				all(p -> p(obj), properties)
			)
			
			# Collect implied filters from all filters
			local implied_filters_set = union(Set{Function}(filters), [f.implied_filters for f in filters]...)
			
			# Store properties as implied properties
			local implied_properties = union(Set{Function}(properties), [f.implied_properties for f in filters]...)
			
			Filter(combined_name, $abstract_type_name, $concrete_type_name, true, additional_predicate, implied_filters_set, implied_properties)
		end
		
		# Build combined name from all components (for registration)
		local combined_name = join([hasproperty(c, :name) ? c.name : string(c) for c in [$(args...),]], "_and_")
		
		# Register with macro-time predictable name (like @DeclareFilter does)
		global const $joined_symbol = $result_filter_var
		
		# Also register with runtime-computed name if different
		if combined_name != $joined_name
			Core.eval(@__MODULE__, :(global const $(Symbol(combined_name)) = $$result_filter_var))
		end
		
		nothing # suppress output
	end)
end

export @FilterIntersection

# Runtime function form of FilterIntersection: looks up the pre-registered filter intersection
# created by @FilterIntersection. The lookup key matches the naming convention used by the macro:
# the filter names joined by "_and_".
function FilterIntersection(args...)
	ValueGlobal(join([f.name for f in args], "_and_"))
end

export FilterIntersection
