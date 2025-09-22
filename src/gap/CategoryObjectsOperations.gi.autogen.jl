# SPDX-License-Identifier: GPL-2.0-or-later
# CAP: Categories, Algorithms, Programming
#
# Implementations
#

#######################################
##
## Technical implications
##
#######################################

Add( PROPAGATION_LIST_FOR_EQUAL_OBJECTS, "IsTerminal" );
Add( PROPAGATION_LIST_FOR_EQUAL_OBJECTS, "IsInitial" );
Add( PROPAGATION_LIST_FOR_EQUAL_OBJECTS, "IsProjective" );
Add( PROPAGATION_LIST_FOR_EQUAL_OBJECTS, "IsInjective" );
Add( PROPAGATION_LIST_FOR_EQUAL_OBJECTS, "IsZeroForObjects" );

###################################
##
## Constructive Object-sets
##
###################################

# This method should not be selected when the two objects belong to the same category and the category can compute IsEqualForObjects.
@InstallMethod( IsEqualForObjects,
                    [ IsCapCategory, IsCapCategoryObject, IsCapCategoryObject ],

  function( cat, object_1, object_2 )
    
    if (@not HasCapCategory( object_1 ))
        
        Error( @Concatenation( "the object \"", StringGAP( object_1 ), "\" has no CAP category" ) );
        
    end;
    
    if (@not HasCapCategory( object_2 ))
        
        Error( @Concatenation( "the object \"", StringGAP( object_2 ), "\" has no CAP category" ) );
        
    end;
    
    if (@not IsIdenticalObj( CapCategory( object_1 ), cat ))
        
        Error( @Concatenation( "the object \"", StringGAP( object_1 ), "\" does not belong to the CAP category <cat>" ) );
        
    elseif (@not IsIdenticalObj( CapCategory( object_2 ), cat ))
        
        Error( @Concatenation( "the object \"", StringGAP( object_2 ), "\" does not belong to the CAP category <cat>" ) );
        
    else
        
        # convenience: as long as the objects are identical, everything "just works"
        if (IsIdenticalObj( object_1, object_2 ))
            
            return true;
            
        else
            
            Error( "Cannot decide whether the object \"", StringGAP( object_1 ), "\" and the object \"", StringGAP( object_2 ), "\" are equal. You can fix this error by installing `IsEqualForObjects` in <cat> or possibly avoid it by enabling strict caching\n" );
            
        end;
        
    end;
    
end );

##
@InstallMethod( ==,
               [ IsCapCategoryObject, IsCapCategoryObject ],
  function( object_1, object_2 )

    if (CapCategory( object_1 ).input_sanity_check_level > 0 || CapCategory( object_2 ).input_sanity_check_level > 0 )
        if (@not IsIdenticalObj( CapCategory( object_1 ), CapCategory( object_2 ) ))
            Error( @Concatenation( "the object \"", StringGAP( object_1 ), "\" and the object \"", StringGAP( object_2 ), "\" do not belong to the same CAP category" ) );
        end;
    end;
               
  return IsEqualForObjects( object_1, object_2 );
end );

#######################################
##
## Operations
##
#######################################

##
@InstallMethod( /,
               [ IsObject, IsCapCategory ],
               
  function( object_datum, cat )
    
    if (@not CanCompute( cat, "ObjectConstructor" ))
        
        Error( "You are calling the generic \"/\" method, but <cat> does not have an object constructor. Please add one or install a special version of \"/\"." );
        
    end;
    
    return ObjectConstructor( cat, object_datum );
    
end );

##
@InstallMethod( IsWellDefined,
               [ IsCapCategoryObject ],
  IsWellDefinedForObjects
);

##
@InstallMethod( IsZero,
               [ IsCapCategoryObject ],
                  
IsZeroForObjects );

##
@InstallMethod( IsEqualForCache,
               [ IsCapCategoryObject, IsCapCategoryObject ],
               
  ( obj1, obj2 ) -> IsEqualForCacheForObjects( CapCategory( obj1 ), obj1, obj2 ) );

##
# generic fallback to IsIdenticalObj
@InstallMethod( IsEqualForCacheForObjects,
               [ IsCapCategory, IsCapCategoryObject, IsCapCategoryObject ],
               
  ( cat, obj1, obj2 ) -> IsIdenticalObj( obj1, obj2 ) );

##
@InstallMethod( SetOfObjectsAsUnresolvableAttribute,
        [ IsCapCategory ],
        
  SetOfObjectsOfCategory );

#= comment for Julia
##
@InstallMethod( SetOfObjects,
        [ IsCapCategory && HasOppositeCategory ],
        
  function( cat_op )
    
    return List( SetOfObjects( OppositeCategory( cat_op ) ), obj -> ObjectConstructor( cat_op, obj ) );
    
end );
# =#

##
@InstallMethod( RandomObject, [ IsCapCategory, IsInt ], RandomObjectByInteger );

##
@InstallMethod( RandomObject, [ IsCapCategory, IsList ], RandomObjectByList );

##
@InstallMethod( Simplify,
               [ IsCapCategoryObject ],
  function( object )
    
    return SimplifyObject( object, infinity );
    
end );
