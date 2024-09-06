# SPDX-License-Identifier: GPL-2.0-or-later
# CAP: Categories, Algorithms, Programming
#
# Implementations
#

#############################################################################
##
## Chapter Product category
##
#############################################################################

# backwards compatibility
@BindGlobal( "IsCapCategoryProductObjectRep", IsCapCategoryProductObject );

# backwards compatibility
@BindGlobal( "IsCapCategoryProductMorphismRep", IsCapCategoryProductMorphism );

# backwards compatibility
@BindGlobal( "IsCapCategoryProductTwoCellRep", IsCapCategoryProductTwoCell );

@BindGlobal( "TheTypeOfCapCategoryProductObjects",
        NewType( TheFamilyOfCapCategoryObjects,
                IsCapCategoryProductObject ) );

@BindGlobal( "TheTypeOfCapCategoryProductMorphisms",
        NewType( TheFamilyOfCapCategoryMorphisms,
                IsCapCategoryProductMorphism ) );

@BindGlobal( "TheTypeOfCapCategoryProductTwoCells",
        NewType( TheFamilyOfCapCategoryTwoCells,
                IsCapCategoryProductTwoCell ) );

###################################
##
## Section Fallback methods for functors
##
###################################

##
@InstallMethod( Components,
               [ IsCapProductCategory ],
               
  i -> [ i ] );

##
@InstallMethod( Components,
               [ IsCapCategoryProductObject ],
               
  i -> [ i ] );

##
@InstallMethod( Components,
               [ IsCapCategoryProductMorphism ],
               
  i -> [ i ] );

##
@InstallMethod( Components,
               [ IsCapCategoryProductTwoCell ],
               
  i -> [ i ] );

###################################
##
## Section Constructor
##
###################################

@BindGlobal( "CAP_INTERNAL_CREATE_PRODUCT_ARGUMENT_LIST",
  
  function( arg_list )
    local nr_components, current_argument, i, j, current_mat, new_args;
    
    i = 1;
    
    while IsInt( arg_list[ i ] )
        i = i + 1;
    end;
    
    if (IsCapCategoryCell( arg_list[ 1 ] ) || IsCapCategory( arg_list[ 1 ] ))
        
        nr_components = Length( arg_list[ 1 ] );
        
    elseif (IsList( arg_list[ 1 ] ))
        
        nr_components = Length( arg_list[ 1 ][ 1 ] );
        
    end;
    
    new_args = List( (1):(nr_components), i -> [ ] );
    
    for i in (1):(Length( arg_list ))
        
        current_argument = arg_list[ i ];
        
        if (IsCapCategoryCell( current_argument ) || IsCapCategory( current_argument ))
            
            for j in (1):(nr_components)
                new_args[ j ][ i ] = current_argument[ j ];
            end;
            
        elseif (IsInt( current_argument ))
            
            for j in (1):(nr_components)
                new_args[ j ][ i ] = current_argument;
            end;
            
        elseif (IsList( current_argument ))
            
            current_mat = TransposedMat( List( current_argument, Components ) );
            
            for j in (1):(nr_components)
                new_args[ j ][ i ] = current_mat[ j ];
            end;
            
        else
            
            Error( "Unrecognized argument type" );
            
        end;
        
    end;
    
    return new_args;
    
end );

##
@BindGlobal( "CAP_INTERNAL_INSTALL_PRODUCT_ADDS_FROM_CATEGORY",
  
  function( product_category )
    local recnames, current_recname, category_weight_list, current_entry, func,
          current_add, create_func, components;
    
    recnames = RecNames( CAP_INTERNAL_METHOD_NAME_RECORD );
    
    components = Components( product_category );
    
    category_weight_list = List( components, category -> category.derivations_weight_list );
    
    for current_recname in recnames
        
        current_entry = CAP_INTERNAL_METHOD_NAME_RECORD[current_recname];
        
        if (@not ForAll( current_entry.filter_list, filter -> filter in [ "category", "object", "morphism", "twocell", "integer", "list_of_objects", "list_of_morphisms", "list_of_twocells" ] ))
            continue;
        end;
        
        if (@not current_entry.return_type in [ "object", "morphism", "twocell", "bool" ])
            continue;
        end;
        
        if (ForAny( category_weight_list, list -> CurrentOperationWeight( list, current_recname ) == infinity ))
            continue;
        end;
        
        create_func = function( current_name )
            
            if (current_entry.return_type == "bool")
                
                return function( cat, arg... )
                    local product_args, result_list;
                    
                    product_args = CAP_INTERNAL_CREATE_PRODUCT_ARGUMENT_LIST( arg );
                    
                    result_list = List( product_args, i -> CallFuncList( ValueGlobal( current_name ), i ) );
                    
                    return ForAll( result_list, IdFunc );
                    
                end;
                
            elseif (current_entry.return_type == "object")
                
                return function( cat, arg... )
                    local product_args, result_list;
                    
                    product_args = CAP_INTERNAL_CREATE_PRODUCT_ARGUMENT_LIST( arg );
                    
                    result_list = List( product_args, i -> CallFuncList( ValueGlobal( current_name ), i ) );
                    
                    return ProductCategoryObject( cat, result_list );
                    
                end;
                
            elseif (current_entry.return_type == "morphism")
                
                return function( cat, arg... )
                    local product_args, result_list;
                    
                    product_args = CAP_INTERNAL_CREATE_PRODUCT_ARGUMENT_LIST( arg );
                    
                    result_list = List( product_args, i -> CallFuncList( ValueGlobal( current_name ), i ) );
                    
                    return ProductCategoryMorphism( cat, result_list );
                    
                end;
                
            elseif (current_entry.return_type == "twocell")
                
                return function( cat, arg... )
                    local product_args, result_list;
                    
                    product_args = CAP_INTERNAL_CREATE_PRODUCT_ARGUMENT_LIST( arg );
                    
                    result_list = List( product_args, i -> CallFuncList( ValueGlobal( current_name ), i ) );
                    
                    return ProductCategoryTwoCell( cat, result_list );
                    
                end;
                
            else
                
                Error( "this should never happen" );
                
            end;
            
        end;
        
        func = create_func( current_recname );
        
        current_add = ValueGlobal( @Concatenation( "Add", current_recname ) );
        
        current_add( product_category, func );
        
    end;
    
end );

##
InstallMethodWithCrispCache( ProductCategory,
                             [ IsList ],
                        
  function( category_list )
    local product_category, namestring;
    
    if (@not ForAll( category_list, IsFinalized ))
        Error( "all categories for the product must be finalized" );
    end;
    
    ## this is the convention in CapCat
    if (Length( category_list ) == 1)
      
      return category_list[1];
      
    end;
    
    namestring = JoinStringsWithSeparator( List( category_list, Name ), ", " );
    
    namestring = @Concatenation( "Product of: " , namestring );
    
    product_category = CreateCapCategory( namestring, IsCapProductCategory, IsCapCategoryProductObject, IsCapCategoryProductMorphism, IsCapCategoryProductTwoCell );
    
    SetComponents( product_category, category_list );
    
    SetLength( product_category, Length( category_list ) );
    
    CAP_INTERNAL_INSTALL_PRODUCT_ADDS_FROM_CATEGORY( product_category );
    
    Finalize( product_category );
    
    return product_category;
    
end );

##
InstallMethodWithCacheFromObject( ProductCategoryObject,
                                  [ IsCapProductCategory, IsList ],
                        
  function( category, object_list )
    
    return CreateCapCategoryObjectWithAttributes(
        category,
        Components, object_list,
        Length, Length( object_list )
    );
    
end; ArgumentNumber = 1 );

##
InstallMethodWithCacheFromObject( ProductCategoryMorphism,
                                  [ IsCapProductCategory, IsList ],
                                  
  function( category, morphism_list )
    local source, range;
    
    source = ProductCategoryObject( category, List( morphism_list, Source ) );
    range = ProductCategoryObject( category, List( morphism_list, Range ) );
    
    return CreateCapCategoryMorphismWithAttributes(
        category,
        source, range,
        Components, morphism_list,
        Length, Length( morphism_list )
    );
    
end; ArgumentNumber = 1 );

##
InstallMethodWithCacheFromObject( ProductCategoryTwoCell,
                                  [ IsCapProductCategory, IsList ],
                                  
  function( category, twocell_list )
    local source, range;
    
    source = ProductCategoryMorphism( category, List( twocell_list, Source ) );
    range = ProductCategoryMorphism( category, List( twocell_list, Range ) );
    
    return CreateCapCategoryTwoCellWithAttributes(
        category,
        source, range,
        Components, twocell_list,
        Length, Length( twocell_list )
        
    );
    
end; ArgumentNumber = 1 );

##
@InstallMethod( /,
          [ IsList, IsCapProductCategory ],
  function( list, category )

    if (ForAll( list, IsCapCategoryObject ))

      return ProductCategoryObject( category, list );

    elseif (ForAll( list, IsCapCategoryMorphism ))

      return ProductCategoryMorphism( category, list );

    elseif (ForAll( list, IsCapCategoryTwoCell ))

      return ProductCategoryTwoCell( category, list );

    else

      Error( "Wrong input!\n" );

    end;

end );

##
@InstallMethod( getindex,
               [ IsCapProductCategory, IsInt ],
               
  function( category, index )
    
    if (Length( category ) < index)
        
        Error( "index too high, cannot compute this Component" );
        
    end;
    
    return Components( category )[ index ];
    
end );

##
@InstallMethod( getindex,
               [ IsCapCategoryProductObject, IsInt ],
               
  function( cell, index )
    
    if (Length( cell ) < index)
        
        Error( "index too high, cannot compute this Component" );
        
    end;
    
    return Components( cell )[ index ];
    
end );

##
@InstallMethod( getindex,
               [ IsCapCategoryProductMorphism, IsInt ],
               
  function( cell, index )
    
    if (Length( cell ) < index)
        
        Error( "index too high, cannot compute this Component" );
        
    end;
    
    return Components( cell )[ index ];
    
end );

##
@InstallMethod( getindex,
               [ IsCapCategoryProductTwoCell, IsInt ],
               
  function( cell, index )
    
    if (Length( cell ) < index)
        
        Error( "index too high, cannot compute this Component" );
        
    end;
    
    return Components( cell )[ index ];
    
end );

###################################
##
## Section Morphism function
##
###################################

##
InstallMethodWithCacheFromObject( HorizontalPreCompose,
                                  [ IsCapCategoryProductTwoCell, IsCapCategoryProductTwoCell ],
               
  function( twocell_left, twocell_right )
    local left_comp, right_comp;
    
    left_comp = Components( twocell_left );
    
    right_comp = Components( twocell_right );
    
    return ProductCategoryTwoCell( CapCategory( twocell_left ), List( (1):(Length( twocell_left )), i -> HorizontalPreCompose( left_comp[ i ], right_comp[ i ] ) ) );
    
end );

##
InstallMethodWithCacheFromObject( VerticalPreCompose,
                                  [ IsCapCategoryProductTwoCell, IsCapCategoryProductTwoCell ],
               
  function( twocell_left, twocell_right )
    local left_comp, right_comp;
    
    left_comp = Components( twocell_left );
    
    right_comp = Components( twocell_right );
    
    return ProductCategoryTwoCell( CapCategory( twocell_left ), List( (1):(Length( twocell_left )), i -> VerticalPreCompose( left_comp[ i ], right_comp[ i ] ) ) );
    
end );


###################################
##
## Functors on the product category
##
###################################

##
InstallMethodWithCache( DirectProductFunctor,
                        [ IsCapCategory, IsInt ],
               
  function( category, number_of_arguments )
    local direct_product_functor;
    
    direct_product_functor = CapFunctor( 
      @Concatenation( "direct_product_on_", Name( category ), "_for_", StringGAP( number_of_arguments ), "_arguments" ),
      ProductCategory( List( (1):(number_of_arguments), c -> category ) ),
      category 
    );
    
    AddObjectFunction( direct_product_functor,
    
      function( object )
        
        return CallFuncList( DirectProduct, Components( object ) );
        
    end );
    
    AddMorphismFunction( direct_product_functor,
    
      function( new_source, morphism_list, new_range )
        local source, new_source_list;
        
        new_source_list = List( morphism_list, Source );
        
        source = List( (1):(number_of_arguments), i -> 
                        PreCompose( ProjectionInFactorOfDirectProduct( new_source_list, i ), morphism_list[i] ) );
        
        return CallFuncList( UniversalMorphismIntoDirectProduct, source );
        
   end );
   
   return direct_product_functor;
   
end );

##
InstallMethodWithCache( CoproductFunctor,
                        [ IsCapCategory, IsInt ],
               
  function( category, number_of_arguments )
    local coproduct_functor;
    
    coproduct_functor = CapFunctor( 
      @Concatenation( "coproduct_on_", Name( category ), "_for_", StringGAP( number_of_arguments ), "_arguments" ),
      ProductCategory( List( (1):(number_of_arguments), c -> category ) ),
      category 
    );
    
    AddObjectFunction( coproduct_functor,
    
      function( object )
        
        return Coproduct( Components( object ) );
        
    end );
    
    AddMorphismFunction( coproduct_functor,
    
      function( new_source, morphism_list, new_range )
        local sink, new_range_list;
        
        new_range_list = List( morphism_list, Range );
        
        sink = List( (1):(number_of_arguments), i -> 
                      PreCompose( morphism_list[i], InjectionOfCofactorOfCoproduct( new_range_list, i ) ) );
        
        return CallFuncList( UniversalMorphismFromCoproduct, sink );
        
   end );
   
   return coproduct_functor;
   
end );

###################################
##
## Section Some hacks
##
###################################

#= comment for Julia
@BindGlobal( "CAP_INTERNAL_PRODUCT_SAVE", Product );

MakeReadWriteGlobal( "Product" );

## HEHE!
Product = function( arg... )
    
    if (@not IsEmpty( arg ))
        
        if (ForAll( arg, IsCapCategory ))
            
            return ProductCategory( arg );
            
        elseif (ForAll( arg, IsCapCategoryCell ))
            
            return arg / ProductCategory( List( arg, CapCategory ) );
            
        end;
        
    end;
    
    return CallFuncList( CAP_INTERNAL_PRODUCT_SAVE, arg );
    
end;

MakeReadOnlyGlobal( "Product" );
# =#

##
@InstallMethod( IsEqualForCache,
               [ IsCapProductCategory, IsCapProductCategory ],
               
  function( category1, category2 )
    local list1, list2, length;
    
    list1 = Components( category1 );
    
    list2 = Components( category2 );
    
    length = Length( list1 );
    
    if (length != Length( list2 ))
        
        return false;
        
    end;
    
    return ForAll( (1):(length), i -> IsEqualForCache( list1[ i ], list2[ i ] ) );
    
end );

##
@InstallMethod( IsEqualForCache,
               [ IsCapCategoryProductObject, IsCapCategoryProductObject ],
               
  function( obj1, obj2 )
    local list1, list2, length;
    
    list1 = Components( obj1 );
    
    list2 = Components( obj2 );
    
    length = Length( list1 );
    
    if (length != Length( list2 ))
        
        return false;
        
    end;
    
    return ForAll( (1):(length), i -> IsEqualForCache( list1[ i ], list2[ i ] ) );
    
end );

##
@InstallMethod( IsEqualForCache,
               [ IsCapCategoryProductMorphism, IsCapCategoryProductMorphism ],
               
  function( obj1, obj2 )
    local list1, list2, length;
    
    list1 = Components( obj1 );
    
    list2 = Components( obj2 );
    
    length = Length( list1 );
    
    if (length != Length( list2 ))
        
        return false;
        
    end;
    
    return ForAll( (1):(length), i -> IsEqualForCache( list1[ i ], list2[ i ] ) );
    
end );

##
@InstallMethod( IsEqualForCache,
               [ IsCapCategoryProductTwoCell, IsCapCategoryProductTwoCell ],
               
  function( obj1, obj2 )
    local list1, list2, length;
    
    list1 = Components( obj1 );
    
    list2 = Components( obj2 );
    
    length = Length( list1 );
    
    if (length != Length( list2 ))
        
        return false;
        
    end;
    
    return ForAll( (1):(length), i -> IsEqualForCache( list1[ i ], list2[ i ] ) );
    
end );
