import AbstractAlgebra

import Nemo
import Nemo.ZZ
import Nemo.QQ

global const IsRing = Filter("IsRing", Nemo.Ring)
global const IsRingElement = Filter("IsRingElement", Nemo.NCRingElement)

# all rings in Nemo seem to have a unit
global const IsRingWithOne = Filter("IsRingWithOne", Nemo.Ring)
global const IsRingElementWithOne = Filter("IsRingElementWithOne", Nemo.NCRingElement)

# Nemo.NCRingElement is a union which we cannot subtype -> create a filter using
# Nemo.NCRingElem (note: "Elem" instead of "Element") which we can use for subtyping
global const IsAbstractRingElementWithOne = Filter("IsAbstractRingElementWithOne", Nemo.NCRingElem)

function HasIsCommutative(R::Nemo.NCRing)
	R isa Nemo.Ring
end

function IsCommutative(R::Nemo.NCRing)
	R isa Nemo.Ring
end

global const Integers = Nemo.ZZ
global const Rationals = Nemo.QQ

global const IsIntegers = Filter("IsIntegers", typeof(Integers))
global const IsRationals = Filter("IsRationals", typeof(Rationals))

function HasIsBezoutRing(R::Nemo.NCRing)
	if IsRationals(R) | IsIntegers(R)
		true
	else
		false
	end
end

function IsBezoutRing(::Union{typeof(Integers), typeof(Rationals)})
	true
end

function HasIsIntegralDomain(R::Nemo.Ring)
	if IsRationals(R) | IsIntegers(R)
		true
	else
		false
	end
end

function IsIntegralDomain(::Union{typeof(Integers), typeof(Rationals)})
	true
end

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

global const IsZZRingElem = Filter("IsZZRingElem", Nemo.ZZRingElem)
global const IsQQFieldElem = Filter("IsQQFieldElem", Nemo.QQFieldElem)

function RingElementFilter(::typeof(Integers))
	IsZZRingElem
end

function RingElementFilter(::typeof(Rationals))
	IsQQFieldElem
end

@InstallMethod( StringGAP, [ IsZZRingElem ], n -> string(n) );

@InstallMethod( StringGAP, [ IsQQFieldElem ], function( n )
	
	str = string( n );
	
	if EndsWith( str, "//1" )
		str[1:length(str) - 3]
	else
		ReplacedString( str, "//", "/" );
	end
	
end );

function Zero(R::Nemo.Ring)
	Nemo.zero(R)
end

function One(R::Nemo.Ring)
	Nemo.one(R)
end

function MinusOne(R::Nemo.Ring)
	-Nemo.one(R)
end

function /(elem::AbstractAlgebra.NCRingElement, ::typeof(Integers))
	Nemo.ZZ(BigInt(elem))
end

function /(elem::AbstractAlgebra.NCRingElement, ::typeof(Rationals))
	Nemo.QQ(Rational{BigInt}(elem))
end

function in(elem::AbstractAlgebra.NCRingElement, ::typeof(Integers))
	elem isa Nemo.ZZRingElem
end

function in(elem::AbstractAlgebra.NCRingElement, ::typeof(Rationals))
	elem isa Nemo.QQFieldElem
end
