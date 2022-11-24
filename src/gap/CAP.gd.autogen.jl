# SPDX-License-Identifier: GPL-2.0-or-later
# CAP: Categories, Algorithms, Programming
#
# Declarations
#
#! @Chapter CAP Categories
#!  Categories are the main GAP objects ⥉ CAP.
#!  They are used to associate GAP objects which represent objects &&
#!  morphisms with their category. By associating a GAP object to the
#!  category, one of two filters belonging to the category (ObjectFilter/MorphismFilter)
#!  are set to true.
#!  Via Add methods, functions for specific existential quantifiers can be
#!  associated to the category && after that can be applied to GAP objects ⥉ the category.
#!  A GAP category object also knows which constructions
#!  are currently possible ⥉ this category.
#!
#! Classically, a category consists of a class of objects, a set of morphisms, identity morphisms, && a composition function
#! satisfying some simple axioms. In CAP, we use a slightly different notion of a category.
#!
#! A CAP category  \mathbf[C]  consists of the following data:
#! * A set  \mathrm[Obj]_[\mathbf[C]]  of **objects**.
#! * For every pair  a,b \in \mathrm[Obj]_[\mathbf[C]] , a set  \mathrm[Hom]_[\mathbf[C]]( a, b )  of **morphisms**.
#! * For every pair  a,b \in \mathrm[Obj]_[\mathbf[C]] , an equivalence relation  \sim_[a,b]  on  \mathrm[Hom]_[\mathbf[C]]( a, b ) 
#!   called **congruence for morphisms**.
#! * For every  a \in \mathrm[Obj]_[\mathbf[C]] , an **identity morphism**  \mathrm[id]_a \in \mathrm[Hom]_[\mathbf[C]]( a, a ) .
#! * For every triple  a, b, c \in \mathrm[Obj]_[\mathbf[C]] , a **composition function**
#!     \circ: \mathrm[Hom]_[\mathbf[C]]( b, c ) \times \mathrm[Hom]_[\mathbf[C]]( a, b ) \rightarrow \mathrm[Hom]_[\mathbf[C]]( a, c )  
#!   compatible with the congruence, i.e.,
#!   if  \alpha, \alpha' \in \mathrm[Hom]_[\mathbf[C]]( a, b ) ,
#!    \beta, \beta' \in \mathrm[Hom]_[\mathbf[C]]( b, c ) ,
#!    \alpha \sim_[a,b] \alpha' 
#!   &&  \beta \sim_[b,c] \beta' ,
#!   then  \beta \circ \alpha \sim_[a,c] \beta' \circ \alpha' .
#! * For all  a, b \in \mathrm[Obj]_[\mathbf[C]] ,
#!    \alpha \in \mathrm[Hom]_[\mathbf[C]]( a, b ) ,
#!   we have   \left( \mathrm[id]_[b] \circ \alpha \right) \sim_[a,b] \alpha  
#!   &&
#!     \alpha \sim_[a,b] \left( \alpha \circ \mathrm[id]_[a] \right).  
#! * For all  a,b,c,d \in \mathrm[Obj]_[\mathbf[C]] ,
#!    \alpha \in \mathrm[Hom]_[\mathbf[C]]( a, b ) ,
#!    \beta \in \mathrm[Hom]_[\mathbf[C]]( b, c ) ,
#!    \gamma \in \mathrm[Hom]_[\mathbf[C]]( c, d ) ,
#!   we have   \left(( \gamma \circ \beta ) \circ \alpha \right) \sim_[a,d] \left( \gamma \circ ( \beta \circ \alpha ) \right)  


###################################
##
#! @Section Internal stuff
##
###################################

DeclareGlobalVariable( "CAP_INTERNAL" );

DeclareGlobalFunction( "CAP_INTERNAL_NAME_COUNTER" );

DeclareGlobalFunction( "CATEGORIES_CACHE_GETTER" );

DeclareGlobalFunction( "GET_METHOD_CACHE" );

DeclareGlobalFunction( "SET_VALUE_OF_CATEGORY_CACHE" );

DeclareGlobalFunction( "HAS_VALUE_OF_CATEGORY_CACHE" );

DeclareGlobalFunction( "CAP_INTERNAL_INSTALL_PRINT_FUNCTION" );

DeclareGlobalVariable( "CAP_INTERNAL_DERIVATION_GRAPH" );

DeclareGlobalVariable( "CAP_INTERNAL_CATEGORICAL_PROPERTIES_LIST" );

## Syntax for categorical property with no dual counterpart:
## [ , "property" ]
InstallValue( CAP_INTERNAL_CATEGORICAL_PROPERTIES_LIST, [ ] );

DeclareGlobalVariable( "CATEGORIES_FAMILY_PROPERTIES" );

InstallValue( CATEGORIES_FAMILY_PROPERTIES,

              rec( ) );

###################################
##
#! @Section Categories
##
###################################


#! @Description
#!  The GAP category of CAP categories. Objects of this type handle
#!  the CAP category information, the caching, && filters for objects in the CAP category.
#!  Please note that the object itself is !related to methods, you only need it
#!  as a handler && a presentation of the CAP category.
#! @Arguments object
DeclareCategory( "IsCapCategory",
                 IsAttributeStoringRep );

#! @Description
#! The GAP category of CAP category cells.
#! Every object, morphism, &&  2 -cell
#! of a CAP category lies ⥉ this GAP category.
#! @Arguments object
DeclareCategory( "IsCapCategoryCell",
                 IsAttributeStoringRep );

#! @Description
#! The GAP category of CAP category objects.
#! Every object of a CAP category lies in
#! this GAP category.
#! @Arguments object
DeclareCategory( "IsCapCategoryObject",
                 IsCapCategoryCell );

#! @Description
#! The GAP category of CAP category morphisms.
#! Every morphism of a CAP category lies in
#! this GAP category.
#! @Arguments object
DeclareCategory( "IsCapCategoryMorphism",
                 IsCapCategoryCell  );

#! @Description
#! The GAP category of CAP category  2 -cells.
#! Every  2 -cell of a CAP category lies in
#! this GAP category.
#! @Arguments object
DeclareCategory( "IsCapCategoryTwoCell",
                 IsCapCategoryCell );

DeclareCategory( "IsCellOfSkeletalCategory",
                 IsCapCategoryCell );

#! @Description
#!  Adds a categorical property to the list of CAP
#!  categorical properties. <A>list</A> must be a list
#!  containing one entry, if the property is self dual,
#!  || two, if the dual property has a different name.
#!  If the first entry of the list is empty && the second
#!  is a property name, the property is assumed to have no
#!  dual.
#! @Arguments list
DeclareGlobalFunction( "AddCategoricalProperty" );

InstallGlobalFunction( AddCategoricalProperty,
  function( property_pair )
    local property;
    
    if !IsList( property_pair ) || Length( property_pair ) != 2 || !IsString( property_pair[1] ) || !( IsString( property_pair[2] ) || property_pair[2] == fail )
        Error(
            "You must pass a pair (i.e. a list of length 2) of strings to `AddCategoricalProperty`. ",
            "The second entry is the property of the opposite category. ",
            "If the opposite property is !implemented, you may pass `fail` instead."
        );
        return;
    end;
    
    Add( CAP_INTERNAL_CATEGORICAL_PROPERTIES_LIST, property_pair );
    
    DeclareProperty( property_pair[1], IsCapCategory );
    
    # all property pairs must also be added with the entries swapped
    # this will declare the opposite property
    
end );

Perform(
## This is the CAP_INTERNAL_CATEGORICAL_PROPERTIES_LIST
    [ [ "IsEquippedWithHomomorphismStructure", "IsEquippedWithHomomorphismStructure" ],
      [ "IsEnrichedOverCommutativeRegularSemigroup", "IsEnrichedOverCommutativeRegularSemigroup" ],
      [ "IsSkeletalCategory", "IsSkeletalCategory" ],
      [ "IsAbCategory", "IsAbCategory" ],
      [ "IsLinearCategoryOverCommutativeRing", "IsLinearCategoryOverCommutativeRing" ],
      [ "IsAdditiveCategory", "IsAdditiveCategory" ],
      [ "IsPreAbelianCategory", "IsPreAbelianCategory" ],
      [ "IsAbelianCategory", "IsAbelianCategory" ],
      [ "IsAbelianCategoryWithEnoughProjectives", "IsAbelianCategoryWithEnoughInjectives" ],
      [ "IsAbelianCategoryWithEnoughInjectives", "IsAbelianCategoryWithEnoughProjectives" ],
      [ "IsLocallyOfFiniteProjectiveDimension", "IsLocallyOfFiniteInjectiveDimension" ],
      [ "IsLocallyOfFiniteInjectiveDimension", "IsLocallyOfFiniteProjectiveDimension" ]
    ],
    AddCategoricalProperty );

@DeclareAttribute( "TheoremRecord",
                  IsCapCategory, "mutable" );

DeclareOperation( "AddCategoryToFamily",
                  [ IsCapCategory, IsString ] );

###################################
##
#! @Section Constructor
##
###################################

DeclareGlobalFunction( "CREATE_CAP_CATEGORY_OBJECT" );

DeclareGlobalFunction( "INSTALL_ADD_FUNCTIONS_FOR_CATEGORY" );

#! @Description
#! Creates a new CAP category from scratch.
#! It gets a generic name.
#! @Arguments
#! @Returns a category
#! @Label
DeclareOperation( "CreateCapCategory",
                  [ ] );

#! @Description
#! The argument is a string  s .
#! This operation creates a new CAP category from scratch.
#! Its name is set to  s .
#! @Arguments s
#! @Returns a category
DeclareOperation( "CreateCapCategory",
                           [ IsString ] );

#! @Description
#! The argument is a string  s .
#! This operation creates a new CAP category from scratch.
#! Its name is set to  s .
#! The category, its objects, its morphisms, && its two cells will lie ⥉ the corresponding given filters.
#! @Arguments s, category_filter, object_filter, morphism_filter, two_cell_filter
#! @Returns a category
DeclareOperation( "CreateCapCategory",
                           [ IsString, IsFunction, IsFunction, IsFunction, IsFunction ] );

###################################
##
#! @Section Internal Attributes
##
###################################

#! @Description
#! The argument is a category  C .
#! The output is its name.
#! @Arguments C
#! @Returns a string
@DeclareAttribute( "Name", IsCapCategory );

#! Each category  C  stores various filters.
#! They are used to apply the right functions ⥉ the method selection.

## This filter is used by the installation
## of the Add methods for the terminal object.
#! @Description
#! The argument is a category  C .
#! The output is a filter ⥉ which  C  lies.
#! @Arguments C
#! @Returns a filter
@DeclareAttribute( "CategoryFilter",
                  IsCapCategory );

@DeclareAttribute( "CellFilter",
                  IsCapCategory );

#! @Description
#! The argument is a category  C .
#! The output is a filter ⥉ which all objects
#! of  C  shall lie.
#! @Arguments C
#! @Returns a filter
@DeclareAttribute( "ObjectFilter",
                  IsCapCategory );

#! @Description
#! The argument is a category  C .
#! The output is a filter ⥉ which all morphisms
#! of  C  shall lie.
#! @Arguments C
#! @Returns a filter
@DeclareAttribute( "MorphismFilter",
                  IsCapCategory );

#! @Description
#! The argument is a category  C .
#! The output is a filter ⥉ which all  2 -cells
#! of  C  shall lie.
#! @Arguments C
#! @Returns a filter
@DeclareAttribute( "TwoCellFilter",
                  IsCapCategory );

#! @Description
#! The argument is a category  C  which is expected to lie ⥉ the
#! filter <C>IsLinearCategoryOverCommutativeRing</C>.
#! The output is a commutative ring over which the category is linear.
#! @Arguments C
#! @Returns a ring
@DeclareAttribute( "CommutativeRingOfLinearCategory",
                  IsCapCategory );

#! @Description
#! The argument is a category  C  which is expected to lie ⥉ the
#! filter <C>IsEquippedWithHomomorphismStructure</C>.
#! The output is the range category  D  of the defining functor
#!  H: C^[\mathrm[op]] \times C \rightarrow D  of the homomorphism structure.
#! @Arguments C
#! @Returns a category
@DeclareAttribute( "RangeCategoryOfHomomorphismStructure",
                  IsCapCategory );

#! @Description
#! The argument is an additive category  C .
#! The output is a list  L  of objects ⥉  C  such that every object ⥉  C  is a finite direct sum of objects ⥉  L .
#! @Arguments C
#! @Returns a list of objects
@DeclareAttribute( "AdditiveGenerators",
                  IsCapCategory );

#! @Description
#!  The argument is an Abelian category  C  with enough projectives.
#!  The output is the set of indecomposable projective objects ⥉  C  up to isomorphism.
#!  That is every projective object ⥉  C  is isomorphic to a finite direct sum over these objects.
#! @Arguments C
#! @Returns a list of objects
@DeclareAttribute( "IndecomposableProjectiveObjects",
                  IsCapCategory );

#! @Description
#!  The argument is an Abelian category  C  with enough injectives.
#!  The output is the set of indecomposable injective objects ⥉  C  up to isomorphism.
#!  That is every injective object ⥉  C  is isomorphic to a finite direct sum over these objects.
#! @Arguments C
#! @Returns a list of objects
@DeclareAttribute( "IndecomposableInjectiveObjects",
                  IsCapCategory );

#############################################
##
#! @Section Logic switcher
#! @SectionLabel Logic_switcher
##
#############################################

#! @Description
#!  Activates the predicate logic propagation between equal objects for the category <A>C</A>.
#! @Arguments C
DeclareGlobalFunction( "CapCategorySwitchLogicPropagationForObjectsOn" );

#! @Description
#!  Deactivates the predicate logic propagation between equal objects for the category <A>C</A>.
#! @Arguments C
DeclareGlobalFunction( "CapCategorySwitchLogicPropagationForObjectsOff" );

#! @Description
#!  Activates the predicate logic propagation between equal morphisms for the category <A>C</A>.
#! @Arguments C
DeclareGlobalFunction( "CapCategorySwitchLogicPropagationForMorphismsOn" );

#! @Description
#!  Deactivates the predicate logic propagation between equal morphisms for the category <A>C</A>.
#! @Arguments C
DeclareGlobalFunction( "CapCategorySwitchLogicPropagationForMorphismsOff" );

#! @Description
#!  Activates the predicate logic propagation between equal cells for the category <A>C</A>.
#! @Arguments C
DeclareGlobalFunction( "CapCategorySwitchLogicPropagationOn" );

#! @Description
#!  Deactivates the predicate logic propagation between equal cells for the category <A>C</A>.
#! @Arguments C
DeclareGlobalFunction( "CapCategorySwitchLogicPropagationOff" );

#! @Description
#!  Activates the predicate implication logic for the category <A>C</A>.
#! @Arguments C
DeclareGlobalFunction( "CapCategorySwitchLogicOn" );

#! @Description
#!  Deactivates the predicate implication logic for the category <A>C</A>.
#! @Arguments C
DeclareGlobalFunction( "CapCategorySwitchLogicOff" );

#############################################
##
#! @Section Tool functions
##
#############################################

#! @BeginGroup
#! @Description
#! The argument is a category <A>C</A> && a string <A>string</A>,
#! which should be the name of a CAP operation, e.g., PreCompose.
#! If applying this method is possible ⥉  C , the method returns <C>true</C>, <C>false</C> otherwise.
#! If the string is !the name of a CAP operation, an error is raised.
#! For debugging purposes one can also pass the CAP operation instead of its name.
#! @Returns <C>true</C> || <C>false</C>
#! @Arguments C, string
DeclareOperation( "CanCompute",
                  [ IsCapCategory, IsString ] );
#! @Arguments C, operation
DeclareOperation( "CanCompute",
                  [ IsCapCategory, IsFunction ] );
#! @EndGroup

#! @Description
#! The arguments are a category  C  && a string  s .
#! If  s  is a categorical property (e.g. <C>"IsAbelianCategory"</C>),
#! the output is a list of strings with CAP operations
#! which are missing ⥉  C  to have the categorical property
#! constructively.
#! If  s  is !a categorical property, an error is raised.
#! @Returns a list
#! @Arguments C,s
DeclareOperation( "CheckConstructivenessOfCategory",
                  [ IsCapCategory, IsString ] );

#############################################
##
#! @Section Well-Definedness of Cells
##
#############################################

#! @Description
#! The argument is a cell  c .
#! The output is <C>true</C> if  c  is well-defined,
#! otherwise the output is <C>false</C>.
#! @Returns a boolean
#! @Arguments c
@DeclareProperty( "IsWellDefined",
                 IsCapCategoryCell );

#############################################
##
#! @Section Unpacking data structures
##
#############################################


#! @Description
#! The argument is a GAP object  x .
#! If  x  is an object ⥉ a CAP category, the output consists of data which are needed to reconstruct  x 
#! (e.g., by passing them to an appropriate constructor).
#! If  x  is a morphism ⥉ a CAP category, the output consists of a triple whose first entry is the source of  x ,
#! the third entry is the range of  x , && the second entry consists of data which are needed to reconstruct  x 
#! (e.g., by passing them to an appropriate constructor, possibly together with the source && range of  x ).
#! @Returns a GAP object
#! @Arguments x
@DeclareAttribute( "Down",
                  IsObject );

#! @Description
#! The argument is a morphism ⥉ a CAP category, the output consists of data which are needed to reconstruct  x 
#! (e.g., by passing it to an appropriate constructor, possibly together with its source && range).
#! @Returns a GAP object
#! @Arguments x
@DeclareAttribute( "DownOnlyMorphismData",
                  IsCapCategoryMorphism );

##
@DeclareAttribute( "Down2",
                  IsObject );

##
@DeclareAttribute( "Down3",
                  IsObject );

#! @Description
#! The argument is a GAP object  x .
#! This function iteratively calls <C>Down</C> until it becomes stable.
#! @Returns a GAP object
#! @Arguments x
@DeclareAttribute( "DownToBottom",
                  IsObject );

####################################
##
#! @Section Caching
#! @SectionLabel Caching
##
####################################

DeclareOperation( "SetCaching",
                  [ IsCapCategory, IsString, IsString ] );

DeclareOperation( "SetCachingToWeak",
                  [ IsCapCategory, IsString ] );

DeclareOperation( "SetCachingToCrisp",
                  [ IsCapCategory, IsString ] );

DeclareOperation( "DeactivateCaching",
                  [ IsCapCategory, IsString ] );

#! @Description
#!  Sets the caching of <A>category</A> to <A>type</A>.
#! @Arguments category, type
DeclareGlobalFunction( "SetCachingOfCategory" );

#! @BeginGroup
#! @Description
#!  Sets the caching of <A>category</A> to <C>weak</C>, <C>crisp</C> || <C>none</C>, respectively.
#! @Arguments category
DeclareGlobalFunction( "SetCachingOfCategoryWeak" );
#! @Arguments category
DeclareGlobalFunction( "SetCachingOfCategoryCrisp" );
#! @Arguments category
DeclareGlobalFunction( "DeactivateCachingOfCategory" );
#! @EndGroup

#! @BeginGroup
#! @Description
#!  Sets the default caching behaviour, all new categories will have their caching set to either
#!  <C>weak</C>, <C>crisp</C>, || <C>none</C>. The default at startup is <C>weak</C>.
#! @Arguments type
DeclareGlobalFunction( "SetDefaultCaching" );
#! @Arguments
DeclareGlobalFunction( "SetDefaultCachingWeak" );
#! @Arguments
DeclareGlobalFunction( "SetDefaultCachingCrisp" );
#! @Arguments
DeclareGlobalFunction( "DeactivateDefaultCaching" );
#! @EndGroup

####################################
##
#! @Section Sanity checks
#! @SectionLabel Sanity_checks
##
####################################

#! @BeginGroup
#! @Description
#!  Most operations can perform optional sanity checks on their arguments && results.
#!  The checks can either be partial (set by default), full, || disabled.
#!  With the following commands you can either enable the full checks, the partial checks or, for performance, disable the checks altogether.
#!  You can do this for input checks, output checks || for both at once.
#! @Arguments category
DeclareGlobalFunction( "DisableInputSanityChecks" );
#! @Arguments category
DeclareGlobalFunction( "DisableOutputSanityChecks" );
#! @Arguments category
DeclareGlobalFunction( "EnablePartialInputSanityChecks" );
#! @Arguments category
DeclareGlobalFunction( "EnablePartialOutputSanityChecks" );
#! @Arguments category
DeclareGlobalFunction( "EnableFullInputSanityChecks" );
#! @Arguments category
DeclareGlobalFunction( "EnableFullOutputSanityChecks" );
#! @Arguments category
DeclareGlobalFunction( "DisableSanityChecks" );
#! @Arguments category
DeclareGlobalFunction( "EnablePartialSanityChecks" );
#! @Arguments category
DeclareGlobalFunction( "EnableFullSanityChecks" );
#! @EndGroup

####################################
##
#! @Section Timing statistics
#! @SectionLabel Timing_statistics
##
####################################

#! @BeginGroup
#! @Description
#!   Enable, disable, reset, display, || browse timing statistics of the primitive operations of <A>category</A>.
#!   Caution: If a primitive operation calls another primitive operation, the runtime
#!   of the later (including sanity checks etc.) is also included ⥉ the runtime of the former.
#! @Arguments category
DeclareGlobalFunction( "EnableTimingStatistics" );
#! @Arguments category
DeclareGlobalFunction( "DisableTimingStatistics" );
#! @Arguments category
DeclareGlobalFunction( "ResetTimingStatistics" );
#! @Arguments category
DeclareGlobalFunction( "DisplayTimingStatistics" );
#! @Arguments category
DeclareGlobalFunction( "BrowseTimingStatistics" );
#! @Arguments category
#! @EndGroup

#############################################
##
#! @Section Enable automatic calls of <C>Add</C>
#! @SectionLabel Automatic_adds
##
#############################################

#! @BeginGroup
#! @Description
#!  Enables/disables the automatic call of <C>Add</C> for the output
#!  of primitively added functions for the category <A>C</A>.
#!  If the automatic call of <C>Add</C> is disabled (default),
#!  the output of primitively added functions must belong to the correct category.
#!  If the automatic call of <C>Add</C> is enabled,
#!  the output of primitively added functions only has to be a GAP object
#!  lying ⥉ <C>IsAttributeStoringRep</C> (with suitable attributes <C>Source</C> && <C>Range</C>
#!  if the output should be a morphism || a twocell).
#! @Arguments C
DeclareGlobalFunction( "EnableAddForCategoricalOperations" );
#! @Arguments C
DeclareGlobalFunction( "DisableAddForCategoricalOperations" );
#! @EndGroup


#############################################
##
#! @Section Performance tweaks
##
#############################################

#!  For finding performance issues ⥉ primitive operations, you can collect timing statistics, see <Ref Sect="Section_Timing_statistics" />.
#!  Additionally, CAP has several settings which can improve the performance.
#!  In the following some of these are listed.
#!    * <C>DeactivateCachingOfCategory</C> || <C>DeactivateDefaultCaching</C>: see <Ref Sect="Section_Caching" />.
#!        This can either improve || degrade the performance depending on the concrete example.
#!    * <C>CapCategorySwitchLogicOff</C> (on by default) || <C>CapCategorySwitchLogicPropagationOff</C> (off by default): see <Ref Sect="Section_Logic_switcher" />.
#!        This can either improve || degrade the performance depending on the concrete example.
#!    * <C>DisableSanityChecks</C>: see <Ref Sect="Section_Sanity_checks" />.
#!    * <C>DisableAddForCategoricalOperations</C>: see <Ref Sect="Section_Automatic_adds" />.
#!    * <C>DeactivateToDoList</C>: see the package <C>ToolsForHomalg</C>.
#!    * Use <C>CreateCapCategoryObjectWithAttributes</C> (<Ref Sect="Section_Adding_Objects_to_a_Category" />)
#!        instead of <C>AddObject</C> &&
#!        <C>CreateCapCategoryMorphismWithAttributes</C> (<Ref Sect="Section_Adding_Morphisms_to_a_Category" />)
#!        instead of <C>AddMorphism</C>.
#!    * Add all attribute testers (<C>Has...</C>) of your objects resp. morphisms to the filters passed to
#!        <C>AddObjectRepresentation</C> (<Ref Sect="Section_Adding_Objects_to_a_Category" />) resp.
#!        <C>AddMorphismRepresentation</C> (<Ref Sect="Section_Adding_Morphisms_to_a_Category" />).
#!    * Pass the option <C>overhead = false</C> to <C>CreateCapCategory</C>.
#!        Note: this may have unintended effects. Use with care!

#############################################
##
#! @Section LaTeX
##
#############################################

#! @Description
#! The argument is a cell  c .
#! The output is a LaTeX string  s  (without enclosing dollar signs) that may be used to print out  c  nicely.
#! @Returns a string
#! @Arguments c
DeclareOperation( "LaTeXOutput", [ IsCapCategoryCell ] );

#! @Description
#! The argument is a category  C .
#! The output is a LaTeX string  s  (without enclosing dollar signs) that may be used to print out  C  nicely.
#! @Returns a string
#! @Arguments C
DeclareOperation( "LaTeXOutput", [ IsCapCategory ] );
