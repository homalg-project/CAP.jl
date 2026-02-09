abstract type AttributeStoringRep <: CAPDict end
global const IsAttributeStoringRep = Filter("IsAttributeStoringRep", AttributeStoringRep)

abstract type Attribute <: Function end

function ==(attr1::Attribute, attr2::Attribute)
	isequal(attr1.name, attr2.name)
end

is_dispatchable(attr::Attribute) = attr.is_dispatchable

CAP_JL_INTERNAL_LIST_OF_PROPERTIES = []

function declare_attribute_or_property(mod, name::String, is_property::Bool, is_dispatchable::Bool = false)
	# attributes and properties might be installed for different parent filters
	# since we do not take the parent filter into account here, we only have to install
	# the attribute or property once
	if isdefined(mod, Symbol(name))
		return nothing
	end
	symbol = Symbol(name)
	symbol_op = Symbol(name, "_OPERATION")
	symbol_tester = Symbol("Has", name)
	symbol_setter = Symbol("Set", name)
	type_symbol = Symbol("TheJuliaAttributeType", name)
	tester_filter_name = "Has" * name
	esc(quote
		global const $symbol_op = $is_dispatchable ? CAP.FilterDispatchedOperation($name * "_OPERATION") : (function $symbol_op end; $symbol_op)
		
		# Mirror GAP behavior - HasProperty/Attribute is a filter
		global const $symbol_tester = let local_name = $name
			Filter( $tester_filter_name,
				IsAttributeStoringRep.abstract_type,
				obj -> haskey(getfield(obj, :dict), Symbol(local_name)))
		end
		CAP_precompile($symbol_tester, (AttributeStoringRep, ))
		
		function $symbol_setter(obj::AttributeStoringRep, value)
			dict = getfield(obj, :dict)
			dict[Symbol($name)] = value
			if IsProperty( $symbol ) && value === true
				for implied_property in $symbol.implied_properties
					Setter(implied_property)(obj, true)
				end
			end
		end
		CAP_precompile($symbol_setter, (AttributeStoringRep, Any))
		
		mutable struct $type_symbol <: Attribute
			name::String
			operation::Union{Function, FilterDispatchedOperation}
			tester::Function
			setter::Function
			is_dispatchable::Bool
			is_property::Bool
			implied_properties::Vector{Attribute}
		end
		
		global const $symbol = $type_symbol($name, $symbol_op, $symbol_tester, $symbol_setter, $is_dispatchable, $is_property, [])
		
		function (::$type_symbol)(obj::IsAttributeStoringRep.abstract_type; kwargs...)
			if !$symbol_tester(obj)
				$symbol_setter(obj, $symbol_op(obj; kwargs...))
			end
			dict = getfield(obj, :dict)
			dict[Symbol($name)]
		end
		
		# Multi-argument fallback for filter-dispatched attributes
		if $is_dispatchable
			function (::$type_symbol)(arg1, arg2, rest...)
				all_args = (arg1, arg2, rest...)
				method_func = CAP.find_filter_method(Symbol($name), all_args...)
				if method_func !== nothing
					return Base.invokelatest(method_func, all_args...)
				else
					error("No method found for ", $name, " with ", length(all_args), " arguments")
				end
			end
		end
		
		if $symbol.is_property
			push!(CAP_JL_INTERNAL_LIST_OF_PROPERTIES, $symbol)
		end
	end)
end

macro DeclareAttribute(name::String, parent_filter, mutability=missing)
	declare_attribute_or_property(__module__, name, false, false)
end

macro DeclareFilterDispatchedAttribute(name::String, parent_filter, mutability=missing)
	declare_attribute_or_property(__module__, name, false, true)
end

export @DeclareAttribute, @DeclareFilterDispatchedAttribute

function IsAttribute( obj )
	obj isa Attribute
end

function Tester( attribute::Attribute )
	attribute.tester
end

function Setter(attribute::Attribute)
	attribute.setter
end

macro DeclareSynonymAttr(name::String, attr)
	symbol = Symbol(name)
	esc(:(global const $symbol = $attr))
end

macro DeclareProperty(name::String, parent_filter)
	declare_attribute_or_property(__module__, name, true, false)
end

macro DeclareFilterDispatchedProperty(name::String, parent_filter)
	declare_attribute_or_property(__module__, name, true, true)
end

export @DeclareProperty, @DeclareFilterDispatchedProperty

function IsProperty( obj )
	obj isa Attribute && obj.is_property
end

function InstallTrueMethod(p1, p2)
	if IsProperty( p1 ) && IsProperty( p2 )
		push!(p2.implied_properties, p1)
	elseif IsFilter( p1 ) && IsFilter( p2 )
		push!(p2.implied_filters, p1)
	else
		throw("InstallTrueMethod can only be used to install implications between properties or between filters")
	end
end

function ListImpliedFilters(prop)
	@assert IsProperty( prop )
	
	flatten = prop -> union([prop], map(flatten, prop.implied_properties)...)
	sort(map(attr -> attr.name, flatten(prop)))
end

function IS_SUBSET_FLAGS(prop2::Attribute, prop1::Attribute) # prop2 => prop1?
	@assert IsProperty( prop1 ) && IsProperty( prop2 )
	
	implied_properties = Vector{Attribute}([ prop2 ])
	
	while !isempty(implied_properties)
		prop = pop!(implied_properties)
		
		if prop === prop1
			return true
		else
			push!(implied_properties, prop.implied_properties...)
		end
	end
	
	return false
end

@DeclareAttribute( "StringGAP", IsObject );
global const StringMutable = StringGAP

function (::typeof(StringGAP))(attr::Attribute)
	if attr.is_property
		string("<Property \"", attr.name, "\">")
	else
		string("<Attribute \"", attr.name, "\">")
	end
end
