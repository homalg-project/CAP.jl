# define functions in CAPJSONExtension here to make sure they are available to the outside world
# see https://discourse.julialang.org/t/we-do-need-exportable-new-structs-and-functions-in-extension/105810 for some background
function JsonStringToGap end
function GapToJsonString end

include("gap_emulation.jl")

# Shared GAP declarations used by otherwise unrelated CAP packages.
@DeclareAttribute( "PseudoInverse", IsObject )
@DeclareAttribute( "Size", IsObject )
@DeclareAttribute( "Cardinality", IsObject )
@DeclareAttribute( "Dimension", IsObject )
@DeclareAttribute( "UnderlyingMorphism", IsObject )
@DeclareAttribute( "AmbientCategory", IsObject )
@DeclareAttribute( "UnderlyingCategory", IsObject )
@DeclareAttribute( "UnderlyingDatum", IsObject )
@DeclareOperation( "Visualize" )

