
```jldoctest
julia> using CAP

julia> true
true

julia> @DeclareFilter( "IsStringsAsCategory", IsCapCategory )

julia> @DeclareFilter( "IsObjectInStringsAsCategory", IsCapCategoryObject )

julia> @DeclareFilter( "IsMorphismInStringsAsCategory", IsCapCategoryMorphism )

julia> @DeclareAttribute( "UnderlyingString", IsObjectInStringsAsCategory )

julia> @DeclareAttribute( "UnderlyingString", IsMorphismInStringsAsCategory )

julia> @BindGlobal( "RemovedCharacters",
               function( str, chars )
                   
                   return Filtered( str, c -> @not c in chars )
                   
           end )

julia> @BindGlobal( "DeleteVowels",
               function( str, n )
                   local vowels
                   
                   vowels = "aeiou"
                   
                   return RemovedCharacters( str , vowels[(1):(Minimum( Length( vowels ), n ))] )
                   
           end )

julia> @BindGlobal( "StringsAsCategoryObject",
             function( cat, string )
               
               return CreateCapCategoryObjectWithAttributes( cat,
                                                             UnderlyingString, string )
               
           end )

julia> @BindGlobal( "StringsAsCategoryMorphism",
             function( cat, source, string, range )
               
               return CreateCapCategoryMorphismWithAttributes( cat,
                                                               source,
                                                               range,
                                                               UnderlyingString, string )
               
           end )

julia> @BindGlobal( "StringsAsCategory",
             function( )
               local category, vowels
               
               category = CreateCapCategoryWithDataTypes( "Category of strings up to vowels",
                                                           IsStringsAsCategory,
                                                           IsObjectInStringsAsCategory,
                                                           IsMorphismInStringsAsCategory,
                                                           IsCapCategoryTwoCell,
                                                           IsStringRep,
                                                           IsStringRep,
                                                           fail )
               
               vowels = "aeiou"
               
               ##
               AddIsEqualForObjects( category,
                 function( cat, a, b )
                 
                   return UnderlyingString( a ) == UnderlyingString( b )
                 
               end )
               
               ##
               AddIsEqualForMorphisms( category,
                 function( cat, alpha, beta )
                   
                   return UnderlyingString( alpha ) == UnderlyingString( beta )
                   
               end )
               
               ##
               AddIsCongruentForMorphisms( category,
                 function( cat, alpha, beta )
                   
                   return RemovedCharacters( UnderlyingString( alpha ), vowels ) == RemovedCharacters( UnderlyingString( beta ), vowels )
                 
               end )
               
               AddIsWellDefinedForObjects( category,
                 function( cat, a )
                     
                     return true
                     
               end)
               
               ##
               AddIsWellDefinedForMorphisms( category,
                   function( cat, alpha )
                       
                       return RemovedCharacters( @Concatenation( UnderlyingString( Source( alpha ) ), UnderlyingString( alpha ) ), vowels ) == RemovedCharacters( UnderlyingString( Range( alpha ) ), vowels )
                       
               end )
               
               ##
               AddPreCompose( category,
                 function( cat, alpha, beta )
                   
                   return StringsAsCategoryMorphism( cat,
                                                     Source( alpha ),
                                                     @Concatenation( UnderlyingString( alpha ), UnderlyingString( beta ) ),
                                                     Range( beta ) )
                   
               end )
               
               ##
               AddIdentityMorphism( category,
                 function( cat, a )
                   
                   return StringsAsCategoryMorphism( cat, a, "", a )
                   
               end )
               
               ## SimplifyObject*
               ##
               AddSimplifyObject( category,
                   function( cat, a, n )
                       local min
                       
                       if (n == 0)
                           Print( "this case must not be handled here" )
                       end
                       
                       min = Minimum( Length( vowels ), n )
                       
                       return StringsAsCategoryObject( cat, RemovedCharacters( UnderlyingString( a ) , vowels[(1):(min)] ) )
                       
               end )
               
               ##
               AddSimplifyObject_IsoFromInputObject( category,
                   function( cat, a, n )
                       
                       if (n == 0)
                           Print( "this case must not be handled here" )
                       end
                       
                       return StringsAsCategoryMorphism( cat, a, "", SimplifyObject( a, n ) )
                       
               end )
               
               ##
               AddSimplifyObject_IsoToInputObject( category,
                   function( cat, a, n )
                       
                       if (n == 0)
                           Print( "this case must not be handled here" )
                       end
                       
                       return StringsAsCategoryMorphism( cat, SimplifyObject( a, n ), "", a)
                       
               end )
               
               ## SimplifyMorphism
               ##
               AddSimplifyMorphism( category,
                   function( cat, alpha, n )
                       local min
                       
                       if (n == 0)
                           Print( "this case must not be handled here" )
                       end
                       
                       min = Minimum( Length( vowels ), n )
                       
                       return StringsAsCategoryMorphism( cat,
                                                         Source( alpha ),
                                                         RemovedCharacters( UnderlyingString( alpha ) , vowels[(1):(min)] ),
                                                         Range( alpha ) )
                       
               end )
               
               ## SimplifySource
               ##
               AddSimplifySource( category,
                   function( cat, alpha, n )
                       local new_source
                       
                       if (n == 0)
                           Print( "this case must not be handled here" )
                       end
                       
                       new_source = StringsAsCategoryObject( cat, DeleteVowels( UnderlyingString( Source( alpha ) ), n ) )
                       
                       return StringsAsCategoryMorphism( cat,
                                                         new_source,
                                                         UnderlyingString( alpha ),
                                                         Range( alpha ) )
                       
               end )
               
               ##
               AddSimplifySource_IsoToInputObject( category,
                   function( cat, alpha, n )
                       
                       if (n == 0)
                           Print( "this case must not be handled here" )
                       end
                       
                       return StringsAsCategoryMorphism( cat,
                                                         Source( SimplifySource( alpha, n ) ),
                                                         "",
                                                         Source( alpha ) )
                       
               end )
               
               ##
               AddSimplifySource_IsoFromInputObject( category,
                   function( cat, alpha, n )
                       
                       if (n == 0)
                           Print( "this case must not be handled here" )
                       end
                       
                       return StringsAsCategoryMorphism( cat,
                                                         Source( alpha ),
                                                         "",
                                                         Source( SimplifySource( alpha, n ) ) )
                       
               end )
               
               ## SimplifyRange
               ##
               AddSimplifyRange( category,
                   function( cat, alpha, n )
                       local new_range
                       
                       if (n == 0)
                          Print( "this case must not be handled here" )
                       end
                       
                       new_range = StringsAsCategoryObject( cat, DeleteVowels( UnderlyingString( Range( alpha ) ), n ) )
                       
                       return StringsAsCategoryMorphism( cat,
                                                         Source( alpha ),
                                                         UnderlyingString( alpha ),
                                                         new_range )
                       
               end )
               
               ##
               AddSimplifyRange_IsoToInputObject( category,
                   function( cat, alpha, n )
                       
                       if (n == 0)
                           Print( "this case must not be handled here" )
                       end
                       
                       return StringsAsCategoryMorphism( cat,
                                                         Range( SimplifyRange( alpha, n ) ),
                                                         "",
                                                         Range( alpha ) )
                       
               end )
               
               ##
               AddSimplifyRange_IsoFromInputObject( category,
                   function( cat, alpha, n )
                       
                       if (n == 0)
                           Print( "this case must not be handled here" )
                       end
                       
                       return StringsAsCategoryMorphism( cat,
                                                         Range( alpha ),
                                                         "",
                                                         Range( SimplifyRange( alpha, n ) ) )
                       
               end )
               
               ## SimplifySourceAndRange
               ##
               AddSimplifySourceAndRange( category,
                   function( cat, alpha, n )
                       local new_source, new_range
                       
                       if (n == 0)
                           Print( "this case must not be handled here" )
                       end
                       
                       new_source = StringsAsCategoryObject( cat, DeleteVowels( UnderlyingString( Source( alpha ) ), n ) )
                       
                       new_range = StringsAsCategoryObject( cat, DeleteVowels( UnderlyingString( Range( alpha ) ), n ) )
                       
                       return StringsAsCategoryMorphism( cat,
                                                         new_source,
                                                         UnderlyingString( alpha ),
                                                         new_range )
                       
               end )
               
               ##
               AddSimplifySourceAndRange_IsoToInputSource( category,
                   function( cat, alpha, n )
                       
                       if (n == 0)
                           Print( "this case must not be handled here" )
                       end
                       
                       return StringsAsCategoryMorphism( cat,
                                                         Source( SimplifySourceAndRange( alpha, n ) ),
                                                         "",
                                                         Source( alpha ) )
                       
               end )
               
               ##
               AddSimplifySourceAndRange_IsoFromInputSource( category,
                   function( cat, alpha, n )
                       
                       if (n == 0)
                           Print( "this case must not be handled here" )
                       end
                       
                       return StringsAsCategoryMorphism( cat,
                                                         Source( alpha ),
                                                         "",
                                                         Source( SimplifySourceAndRange( alpha, n ) ) )
                       
               end )
               
               ##
               AddSimplifySourceAndRange_IsoToInputRange( category,
                   function( cat, alpha, n )
                       
                       if (n == 0)
                           Print( "this case must not be handled here" )
                       end
                       
                       return StringsAsCategoryMorphism( cat,
                                                         Range( SimplifySourceAndRange( alpha, n ) ),
                                                         "",
                                                         Range( alpha ) )
                       
               end )
               
               ##
               AddSimplifySourceAndRange_IsoFromInputRange( category,
                   function( cat, alpha, n )
                       
                       if (n == 0)
                           Print( "this case must not be handled here" )
                       end
                       
                       return StringsAsCategoryMorphism( cat,
                                                         Range( alpha ),
                                                         "",
                                                         Range( SimplifySourceAndRange( alpha, n ) ) )
                       
               end )
               
               ## SimplifyEndo
               ##
               AddSimplifyEndo( category,
                   function( cat, endo, n )
                       local new_object
                       
                       if (n == 0)
                           Print( "this case must not be handled here" )
                       end
                       
                       new_object = StringsAsCategoryObject( category, DeleteVowels( UnderlyingString( Source( endo ) ), n ) )
                       
                       return StringsAsCategoryMorphism( cat,
                                                         new_object,
                                                         UnderlyingString( endo ),
                                                         new_object )
                       
               end )
               
                ##
               AddSimplifyEndo_IsoToInputObject( category,
                   function( cat, endo, n )
                       
                       if (n == 0)
                           Print( "this case must not be handled here" )
                       end
                       
                       return StringsAsCategoryMorphism( cat,
                                                         Source( SimplifyEndo( endo, n ) ),
                                                         "",
                                                         Source( endo ) )
                       
               end )
               
               ##
               AddSimplifyEndo_IsoFromInputObject( category,
                   function( cat, endo, n )
                       
                       if (n == 0)
                           Print( "this case must not be handled here" )
                       end
                       
                       return StringsAsCategoryMorphism( cat,
                                                         Source( endo ),
                                                         "",
                                                         Source( SimplifyEndo( endo, n ) ) )
                       
               end )
               
               Finalize( category )
               
               return category
               
           end )

julia> C = StringsAsCategory();

julia> obj1 = StringsAsCategoryObject( C, "qaeiou" );

julia> obj2 = StringsAsCategoryObject( C, "qxayeziouT" );

julia> mor = StringsAsCategoryMorphism( C, obj1, "xyzaTe", obj2 );

julia> IsWellDefined( mor )
true

julia> IsEqualForObjects( SimplifyObject( obj1, 0 ), obj1 )
true

julia> IsEqualForObjects( SimplifyObject( obj1, 1 ), obj1 )
false

julia> ForAny( [0,1,2,3,4], i -> IsEqualForObjects( SimplifyObject( obj1, i ), SimplifyObject( obj1, i + 1 ) ) )
false

julia> ForAll( [5,6,7,8], i -> IsEqualForObjects( SimplifyObject( obj1, i ), SimplifyObject( obj1, i + 1 ) ) )
true

julia> IsEqualForMorphisms( SimplifyMorphism( mor, 0 ), mor )
true

julia> IsEqualForMorphisms( SimplifyMorphism( mor, 1 ), mor )
false

julia> ForAny( [0,1], i -> IsEqualForMorphisms( SimplifyMorphism( mor, i ), SimplifyMorphism( mor, i + 1 ) ) )
false

julia> ForAll( [2,3,4,5], i -> IsEqualForMorphisms( SimplifyMorphism( mor, i ), SimplifyMorphism( mor, i + 1 ) ) )
true

julia> IsEqualForMorphismsOnMor( SimplifySource( mor, 0 ), mor )
true

julia> IsEqualForMorphismsOnMor( SimplifySource( mor, 1 ), mor )
false

julia> ForAny( [0,1,2,3,4], i -> IsEqualForMorphismsOnMor( SimplifySource( mor, i ), SimplifySource( mor, i + 1 ) ) )
false

julia> ForAll( [5,6,7,8,9], i -> IsEqualForMorphismsOnMor( SimplifySource( mor, i ), SimplifySource( mor, i + 1 ) ) )
true

julia> IsCongruentForMorphisms(
            PreCompose( SimplifySource_IsoFromInputObject( mor, infinity ), SimplifySource( mor, infinity ) ), mor
        )
true

julia> IsCongruentForMorphisms(
            PreCompose( SimplifySource_IsoToInputObject( mor, infinity ), mor ) , SimplifySource( mor, infinity )
        )
true

julia> IsEqualForMorphismsOnMor( SimplifyRange( mor, 0 ), mor )
true

julia> IsEqualForMorphismsOnMor( SimplifyRange( mor, 1 ), mor )
false

julia> ForAny( [0,1,2,3,4], i -> IsEqualForMorphismsOnMor( SimplifyRange( mor, i ), SimplifyRange( mor, i + 1 ) ) )
false

julia> ForAll( [5,6,7,8,9], i -> IsEqualForMorphismsOnMor( SimplifyRange( mor, i ), SimplifyRange( mor, i + 1 ) ) )
true

julia> IsCongruentForMorphisms(
            PreCompose( SimplifyRange( mor, infinity ), SimplifyRange_IsoToInputObject( mor, infinity ) ), mor
        )
true

julia> IsCongruentForMorphisms(
            PreCompose( mor, SimplifyRange_IsoFromInputObject( mor, infinity ) ), SimplifyRange( mor, infinity )
        )
true

julia> IsEqualForMorphismsOnMor( SimplifySourceAndRange( mor, 0 ), mor )
true

julia> IsEqualForMorphismsOnMor( SimplifySourceAndRange( mor, 1 ), mor )
false

julia> ForAny( [0,1,2,3,4], i -> IsEqualForMorphismsOnMor( SimplifySourceAndRange( mor, i ), SimplifySourceAndRange( mor, i + 1 ) ) )
false

julia> ForAll( [5,6,7,8,9], i -> IsEqualForMorphismsOnMor( SimplifySourceAndRange( mor, i ), SimplifySourceAndRange( mor, i + 1 ) ) )
true

julia> IsCongruentForMorphisms(
            mor,
            PreCompose( [ SimplifySourceAndRange_IsoFromInputSource( mor, infinity ),
                          SimplifySourceAndRange( mor, infinity ),
                          SimplifySourceAndRange_IsoToInputRange( mor, infinity ) ] )
        )
true

julia> IsCongruentForMorphisms(
            SimplifySourceAndRange( mor, infinity ),
            PreCompose( [ SimplifySourceAndRange_IsoToInputSource( mor, infinity ),
                          mor,
                          SimplifySourceAndRange_IsoFromInputRange( mor, infinity ) ] )
        )
true

julia> endo = StringsAsCategoryMorphism( C, obj1, "uoiea", obj1 );

julia> IsWellDefined( endo )
true

julia> IsEqualForMorphismsOnMor( SimplifyEndo( endo, 0 ), endo )
true

julia> IsEqualForMorphismsOnMor( SimplifyEndo( endo, 1 ), endo )
false

julia> ForAny( [0,1,2,3,4], i -> IsEqualForMorphismsOnMor( SimplifySourceAndRange( endo, i ), SimplifySourceAndRange( endo, i + 1 ) ) )
false

julia> ForAll( [5,6,7,8,9], i -> IsEqualForMorphismsOnMor( SimplifySourceAndRange( endo, i ), SimplifySourceAndRange( endo, i + 1 ) ) )
true

julia> iota = SimplifyEndo_IsoToInputObject( endo, infinity );

julia> iota_inv = SimplifyEndo_IsoFromInputObject( endo, infinity );

julia> IsCongruentForMorphisms( PreCompose( [ iota_inv, SimplifyEndo( endo, infinity ), iota ] ), endo )
true

```
