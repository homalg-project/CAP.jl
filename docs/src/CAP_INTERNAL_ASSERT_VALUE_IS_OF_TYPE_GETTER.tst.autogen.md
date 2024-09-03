
```jldoctest
julia> using MonoidalCategories; using CAP

julia> true
true

julia> CAP_INTERNAL_ASSERT_VALUE_IS_OF_TYPE_GETTER( @rec( filter = IsFunction, signature = [ [ @rec( filter = IsInt ) ], fail ] ), [ "test value" ] )( x -> x )

julia> CAP_INTERNAL_ASSERT_VALUE_IS_OF_TYPE_GETTER( CapJitDataTypeOfListOf( CapJitDataTypeOfListOf( IsInt ) ), [ "test value" ] )( [ [ 1, 2, 3, 4 ] ] )

julia> CAP_INTERNAL_ASSERT_VALUE_IS_OF_TYPE_GETTER( CapJitDataTypeOfNTupleOf( 2, IsInt, IsStringRep ), [ "test value" ] )( PairGAP( 1, "2" ) )

julia> CAP_INTERNAL_ASSERT_VALUE_IS_OF_TYPE_GETTER( CapJitDataTypeOfCategory( CapCat ), [ "test value" ] )( CapCat )

julia> CAP_INTERNAL_ASSERT_VALUE_IS_OF_TYPE_GETTER( CapJitDataTypeOfObjectOfCategory( CapCat ), [ "test value" ] )( TerminalObject( CapCat ) )

julia> CAP_INTERNAL_ASSERT_VALUE_IS_OF_TYPE_GETTER( CapJitDataTypeOfMorphismOfCategory( CapCat ), [ "test value" ] )( IdentityMorphism( TerminalObject( CapCat ) ) )

julia> CAP_INTERNAL_ASSERT_VALUE_IS_OF_TYPE_GETTER( CapJitDataTypeOfTwoCellOfCategory( CapCat ), [ "test value" ] )( NaturalTransformation( IdentityMorphism( TerminalObject( CapCat ) ), IdentityMorphism( TerminalObject( CapCat ) ) ) )

julia> CAP_INTERNAL_ASSERT_VALUE_IS_OF_TYPE_GETTER( @rec( filter = IsInt ), [ "test value" ] )( 1 )

```
