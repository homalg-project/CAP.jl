# SPDX-License-Identifier: GPL-2.0-or-later
# CAP: Categories, Algorithms, Programming
#
# Implementations
#

#####################################
##
## Reps for object && morphism
##
#####################################

# backwards compatibility
BindGlobal( "IsCapTerminalCategoryObjectRep", IsCapTerminalCategoryObject );

# backwards compatibility
BindGlobal( "IsCapTerminalCategoryMorphismRep", IsCapTerminalCategoryMorphism );

#####################################
##
## Constructor
##
#####################################

InstallValue( CAP_INTERNAL_TERMINAL_CATEGORY,
              
              CreateCapCategory( "TerminalCategory", IsCapTerminalCategory, IsCapTerminalCategoryObject, IsCapTerminalCategoryMorphism, IsCapCategoryTwoCell ) );

SetIsTerminalCategory( CAP_INTERNAL_TERMINAL_CATEGORY, true );

InstallValue( CAP_INTERNAL_TERMINAL_CATEGORY_AS_CAT_OBJECT,
              
              AsCatObject( CAP_INTERNAL_TERMINAL_CATEGORY ) );

##
InstallMethod( UniqueObject,
               [ IsCapTerminalCategory ],
               
  function( category )
    local object;
    
    object = CreateCapCategoryObjectWithAttributes( category, IsZeroForObjects, true );
    
    SetIsWellDefined( object, true );
    
    return object;
    
end );

##
InstallMethod( UniqueMorphism,
               [ IsCapTerminalCategory ],
               
  function( category )
    local object, morphism;
    
    object = UniqueObject( category );
    
    morphism = CreateCapCategoryMorphismWithAttributes( category, object, object, IsOne, true );
    
    SetIsWellDefined( morphism, true );
    
    return morphism;
    
end );

################################
##
## Category functions
##
################################

##
BindGlobal( "INSTALL_TERMINAL_CATEGORY_FUNCTIONS",
            
  function( )
    local obj_function_list, obj_func, morphism_function_list, morphism_function, i;
    
    obj_function_list = [ AddZeroObject,
                           AddKernelObject,
                           AddCokernelObject,
                           AddDirectProduct ];
    
    obj_func = function( arg... ) return UniqueObject( CAP_INTERNAL_TERMINAL_CATEGORY ); end;
    
    for i in obj_function_list
        
        i( CAP_INTERNAL_TERMINAL_CATEGORY, obj_func );
        
    end;
    
    morphism_function_list = [ AddIdentityMorphism,
                                AddPreCompose,
                                AddLiftAlongMonomorphism,
                                AddColiftAlongEpimorphism,
                                AddInverseForMorphisms,
                                AddKernelEmbedding,
                                AddKernelEmbeddingWithGivenKernelObject,
                                AddKernelLiftWithGivenKernelObject,
                                AddCokernelProjection,
                                AddCokernelProjectionWithGivenCokernelObject,
                                AddCokernelColift,
                                AddCokernelColiftWithGivenCokernelObject,
                                AddProjectionInFactorOfDirectProduct,
                                AddProjectionInFactorOfDirectProductWithGivenDirectProduct,
                                AddUniversalMorphismIntoDirectProduct,
                                AddUniversalMorphismIntoDirectProductWithGivenDirectProduct ];
    
    morphism_function = function( arg... ) return UniqueMorphism( CAP_INTERNAL_TERMINAL_CATEGORY ); end;
    
    for i in morphism_function_list
        
        i( CAP_INTERNAL_TERMINAL_CATEGORY, morphism_function );
        
    end;
    
end );

INSTALL_TERMINAL_CATEGORY_FUNCTIONS( );

################################
##
## Functor constructors
##
################################

##
InstallMethod( FunctorFromTerminalCategory,
               [ IsCapCategoryObject ],
               
  function( object )
    local functor;
    
    functor = CapFunctor( Concatenation( "InjectionInto", Name( CapCategory( object ) ) ), CAP_INTERNAL_TERMINAL_CATEGORY, CapCategory( object ) );
    
    functor.terminal_object_functor_object = object;
    
    AddObjectFunction( functor,
                       
      function( arg... )
        
        return functor.terminal_object_functor_object;
        
    end );
    
    AddMorphismFunction( functor,
                         
      function( arg... )
        
        return IdentityMorphism( functor.terminal_object_functor_object );
        
    end );
    
    return functor;
    
end );

##
#= comment for Julia
InstallMethod( FunctorFromTerminalCategory,
               [ IsCapCategoryMorphism && IsOne ],
               
  morphism -> FunctorFromTerminalCategory( Source( morphism ) )
  
);
# =#

Finalize( CAP_INTERNAL_TERMINAL_CATEGORY );
