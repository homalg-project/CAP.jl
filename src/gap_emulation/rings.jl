import AbstractAlgebra

global const IsRing = Filter("IsRing", AbstractAlgebra.Ring)
global const IsRingElement = Filter("IsRingElement", AbstractAlgebra.NCRingElement)

# all rings in AbstractAlgebra seem to have a unit
global const IsRingWithOne = Filter("IsRingWithOne", AbstractAlgebra.Ring)
global const IsRingElementWithOne = Filter("IsRingElementWithOne", AbstractAlgebra.NCRingElement)

# AbstractAlgebra.NCRingElement is a union which we cannot subtype -> create a filter using
# AbstractAlgebra.NCRingElem (note: "Elem" instead of "Element") which we can use for subtyping
global const IsAbstractRingElementWithOne = Filter("IsAbstractRingElementWithOne", AbstractAlgebra.NCRingElem)

function HasIsCommutative(R::AbstractAlgebra.NCRing)
	R isa AbstractAlgebra.Ring
end

function IsCommutative(R::AbstractAlgebra.NCRing)
	R isa AbstractAlgebra.Ring
end

global const Integers = AbstractAlgebra.ZZ
global const Rationals = AbstractAlgebra.QQ

global const IsIntegers = Filter("IsIntegers", AbstractAlgebra.Integers{BigInt})
global const IsRationals = Filter("IsRationals", AbstractAlgebra.Rationals{BigInt})

function HasRingFilter(::Union{typeof(Integers), typeof(Rationals)})
	true
end

function RingFilter(::typeof(Integers))
	IsIntegers
end

function RingFilter(::typeof(Rationals))
	IsRationals
end

function HasRingElementFilter(::Union{typeof(Integers), typeof(Rationals)})
	true
end

function RingElementFilter(::typeof(Integers))
	IsBigInt
end

function RingElementFilter(::typeof(Rationals))
	IsRat
end

function Zero(R::Union{typeof(Integers), typeof(Rationals)})
	zero(R)
end
