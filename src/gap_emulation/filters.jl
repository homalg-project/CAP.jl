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
	isa(obj, filter.abstract_type) && filter.additional_predicate(obj)
end

function IsFilter( obj )
	obj isa Filter
end

macro DeclareFilter(name::String, parent_filter::Union{Symbol,Expr} = :IsObject)
	filter_symbol = Symbol(name)
	abstract_type_symbol = Symbol("TheJuliaAbstractType", name)
	concrete_type_symbol = Symbol("TheJuliaConcreteType", name)
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
