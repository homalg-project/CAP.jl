# SPDX-License-Identifier: GPL-2.0-or-later
# CAP: Categories, Algorithms, Programming
#
# Implementations
#
#! @Chapter Managing Derived Methods

@BindGlobal( "TheFamilyOfDerivations",
            NewFamily( "TheFamilyOfDerivations" ) );
@BindGlobal( "TheFamilyOfDerivationGraphs",
            NewFamily( "TheFamilyOfDerivationGraphs" ) );
@BindGlobal( "TheFamilyOfOperationWeightLists",
            NewFamily( "TheFamilyOfOperationWeightLists" ) );

@BindGlobal( "TheTypeOfDerivedMethods", NewType( TheFamilyOfDerivations, IsDerivedMethod ) );
@BindGlobal( "TheTypeOfDerivationsGraphs", NewType( TheFamilyOfDerivationGraphs, IsDerivedMethodGraph ) );
@BindGlobal( "TheTypeOfOperationWeightLists", NewType( TheFamilyOfOperationWeightLists, IsOperationWeightList ) );

@InstallGlobalFunction( "ActivateDerivationInfo",
  function( )
    SetInfoLevel( DerivationInfo, 1 );
end );

@InstallGlobalFunction( "DeactivateDerivationInfo",
  function( )
    SetInfoLevel( DerivationInfo, 0 );
end );

@InstallGlobalFunction( CreateDerivation, function( target_op_name, description, used_ops_with_multiples_and_category_getters, func, weight, category_filter, loop_multiplier, category_getters )
  local number_of_proposed_arguments, current_function_argument_number, used_op_names_with_multiples_and_category_getters, collected_list, wrapped_category_filter, derivation, x;
    
    if (target_op_name != "internal dummy function of a final derivation")
        
        if (@not @IsBound( CAP_INTERNAL_METHOD_NAME_RECORD[target_op_name] ))
            
            Error( "trying to create a derviation for a method not in CAP_INTERNAL_METHOD_NAME_RECORD" );
            
        end;
        
        number_of_proposed_arguments = Length( CAP_INTERNAL_METHOD_NAME_RECORD[target_op_name].filter_list );
        
        current_function_argument_number = NumberArgumentsFunction( func );
        
        if (current_function_argument_number >= 0 && current_function_argument_number != number_of_proposed_arguments)
            
            Error( "while adding a derivation for ", target_op_name, ": given function has ", current_function_argument_number, " arguments but should have ", number_of_proposed_arguments );
            
        end;
        
    end;
    
    #= comment for Julia
    if (PositionSublist( StringGAP( category_filter ), "CanCompute" ) != fail)
        
        Print( "WARNING: The CategoryFilter of a derivation for ", target_op_name, " uses `CanCompute`. Please register all preconditions explicitly.\n" );
        
    end;
    # =#
    
    # canonicalize used ops
    used_op_names_with_multiples_and_category_getters = [ ];
    
    for x in used_ops_with_multiples_and_category_getters
        
        if (Length( x ) < 2 || !(IsFunction( x[1] )) || @not IsInt( x[2] ))
            
            Error( "preconditions must be of the form `[op, mult, getter]`, where `getter` is optional" );
            
        end;
        
        if ((Length( x ) == 2 || (Length( x ) == 3 && x[3] == fail)) && NameFunction( x[1] ) == target_op_name)
            
            Error( "A derivation for ", target_op_name, " has itself as a precondition. This is not supported because we cannot compute a well-defined weight.\n" );
            
        end;
        
        if (Length( x ) == 2)
            
            Add( used_op_names_with_multiples_and_category_getters, [ NameFunction( x[1] ), x[2], fail ] );
            
        elseif (Length( x ) == 3)
            
            if (x != fail && !(IsFunction( x[3] ) && NumberArgumentsFunction( x[3] ) == 1))
                
                Error( "the category getter must be a single-argument function" );
                
            end;
            
            Add( used_op_names_with_multiples_and_category_getters, [ NameFunction( x[1] ), x[2], x[3] ] );
            
        else
            
            Error( "The list of preconditions must be a list of pairs or triples." );
            
        end;
        
    end;
    
    #= comment for Julia
    if (target_op_name != "internal dummy function of a final derivation")
        
        collected_list = CAP_INTERNAL_FIND_APPEARANCE_OF_SYMBOL_IN_FUNCTION( func, RecNames( CAP_INTERNAL_METHOD_NAME_RECORD ), loop_multiplier, CAP_INTERNAL_METHOD_RECORD_REPLACEMENTS, category_getters );
        
        if (Length( collected_list ) != Length( used_op_names_with_multiples_and_category_getters ) || @not ForAll( collected_list, c -> c in used_op_names_with_multiples_and_category_getters ))
            
            SortBy( used_op_names_with_multiples_and_category_getters, x -> x[1] );
            SortBy( collected_list, x -> x[1] );
            
            Print(
                "WARNING: You have installed a derivation for ", target_op_name, " with preconditions ", used_op_names_with_multiples_and_category_getters,
                " but the automated detection has detected the following list of preconditions: ", collected_list, ".\n",
                "If this is a bug in the automated detection, please report it.\n"
            );
            
        end;
        
    end;
    # =#
    
    if (NumberArgumentsFunction( category_filter ) == 0 || NumberArgumentsFunction( category_filter ) > 1)
        
        Error( "the CategoryFilter of a derivation must accept exactly one argument" );
        
    end;
    
    if (ForAny( used_op_names_with_multiples_and_category_getters, x -> x[3] != fail ) && category_filter == IsCapCategory)
        
        Print( "WARNING: A derivation for ", target_op_name, " depends on other categories (e.g. RangeCategoryOfHomomorphismStructure) but does no test via the CategoryFilter if the other categories are available (e.g. by testing HasRangeCategoryOfHomomorphismStructure).\n" );
        
    end;
    
    if (IsProperty( category_filter ))
        
        # for Julia
        wrapped_category_filter = cat -> Tester( category_filter )( cat ) && category_filter( cat );
        
        #= comment for Julia
        wrapped_category_filter = Tester( category_filter ) && category_filter;
        # =#
        
    else
        
        wrapped_category_filter = category_filter;
        
    end;
    
    derivation = CreateGapObjectWithAttributes( TheTypeOfDerivedMethods,
        Description, description,
        AdditionalWeight, weight,
        DerivationFunction, func,
        CategoryFilter, wrapped_category_filter,
        TargetOperation, target_op_name,
        UsedOperationsWithMultiplesAndCategoryGetters, used_op_names_with_multiples_and_category_getters
    );
    
    return derivation;
    
end );

@InstallMethod( StringGAP,
               [ IsDerivedMethod ],
function( d )
  return @Concatenation( "derivation ", Description( d ),
                        " of operation ", TargetOperation( d ) );
end );

@InstallMethod( ViewString,
               [ IsDerivedMethod ],
function( d )
  return @Concatenation( "<", StringGAP( d ), ">" );
end );

@InstallMethod( IsApplicableToCategory,
               [ IsDerivedMethod, IsCapCategory ],
function( d, C )
  return CategoryFilter( d )( C );
end );

@InstallMethod( InstallDerivationForCategory,
               [ IsDerivedMethod, IsPosInt, IsCapCategory ],
@FunctionWithNamedArguments(
  [
    [ "IsFinalDerivation", false ],
  ],
  function( CAP_NAMED_ARGUMENTS, d, weight, C )
    local method_name, func;
    
    method_name = TargetOperation( d );
    func = DerivationFunction( d );
    
    if (HasFunctionCalledBeforeInstallation( d ))
        
        FunctionCalledBeforeInstallation( d )( C );
        
    end;
    
    AddCapOperation( method_name, C, func, weight; IsDerivation = !(IsFinalDerivation), IsFinalDerivation = IsFinalDerivation );
    
end ) );

@InstallMethod( MakeDerivationGraph,
               [ IsDenseList ],
function( operations )
  local G, op_name;
  G = @rec( derivations_by_target = @rec(),
              derivations_by_used_ops = @rec() );
  G = ObjectifyWithAttributes( G, TheTypeOfDerivationsGraphs );
  
  SetOperations( G, operations );
  
  for op_name in operations
    G.derivations_by_target[op_name] = [];
    G.derivations_by_used_ops[op_name] = [];
  end;
  
  # derivations not using any operations
  G.derivations_by_used_ops.none = [];
  
  return G;
end );

@InstallMethod( AddOperationsToDerivationGraph,
               [ IsDerivedMethodGraph, IsDenseList ],
               
  function( graph, operations )
    local op_name;
    
    Append( Operations( graph ), operations );
    
    for op_name in operations
        
        graph.derivations_by_target[op_name] = [];
        graph.derivations_by_used_ops[op_name] = [];
        
    end;
    
end );

@InstallMethod( StringGAP,
               [ IsDerivedMethodGraph ],
function( G )
  return "derivation graph";
end );

@InstallMethod( ViewString,
               [ IsDerivedMethodGraph ],
function( G )
  return @Concatenation( "<", StringGAP( G ), ">" );
end );

@InstallGlobalFunction( AddDerivation,
  
  function( graph, target_op, description, used_ops_with_multiples_and_category_getters, func, weight, category_filter, loop_multiplier, category_getters, function_called_before_installation, is_with_given_derivation, is_autogenerated_by_CompilerForCAP )
    local target_op_name, derivation, x;
    
    target_op_name = NameFunction( target_op );
    
    derivation = CreateDerivation(
        target_op_name,
        description,
        used_ops_with_multiples_and_category_getters,
        func,
        weight,
        category_filter,
        loop_multiplier,
        category_getters
    );
    
    if (function_called_before_installation != false)
        
        SetFunctionCalledBeforeInstallation( derivation, function_called_before_installation );
        
    end;
    
    derivation.is_with_given_derivation = is_with_given_derivation;
    derivation.is_autogenerated_by_CompilerForCAP = is_autogenerated_by_CompilerForCAP;
    
    if (derivation.is_with_given_derivation && derivation.is_autogenerated_by_CompilerForCAP)
        
        Error( "WithGiven derivations should not be marked as being autogenerated by CompilerForCAP" );
        
    end;
    
    Add( graph.derivations_by_target[target_op_name], derivation );
    derivation.position_in_derivations_by_target = Length( graph.derivations_by_target[target_op_name] );
    
    for x in UsedOperationsWithMultiplesAndCategoryGetters( derivation )
        # We add all operations, even those with category getters: In case the category getter
        # returns the category itself, this allows to recursively trigger derivations correctly.
        Add( graph.derivations_by_used_ops[x[1]], derivation );
    end;
    
    if (IsEmpty( UsedOperationsWithMultiplesAndCategoryGetters( derivation ) ))
        
        Add( graph.derivations_by_used_ops.none, derivation );
        
    end;
    
end );

@BindGlobal( "CAP_INTERNAL_DERIVATION_GRAPH", MakeDerivationGraph( [ ] ) );

@InstallGlobalFunction( AddDerivationToCAP, @FunctionWithNamedArguments(
  [
    # When compiling categories, a derivation does not cause overhead anymore, so we would like to simply set `Weight` to 0.
    # However, the weight 1 is currently needed to prevent the installation of cyclic derivations.
    [ "Weight", 1 ],
    [ "CategoryFilter", IsCapCategory ],
    [ "WeightLoopMultiple", 2 ],
    [ "CategoryGetters", Immutable( @rec( ) ) ],
    [ "FunctionCalledBeforeInstallation", false ],
    [ "is_with_given_derivation", false ],
    [ "is_autogenerated_by_CompilerForCAP", false ],
  ],
  function( CAP_NAMED_ARGUMENTS, target_op, description, used_ops_with_multiples_and_category_getters, func )
    local weight, category_filter, loop_multiplier, category_getters, function_called_before_installation, option_is_with_given_derivation, option_is_autogenerated_by_CompilerForCAP;
    
    weight = Weight;
    category_filter = CategoryFilter;
    loop_multiplier = WeightLoopMultiple;
    category_getters = CategoryGetters;
    function_called_before_installation = FunctionCalledBeforeInstallation;
    option_is_with_given_derivation = is_with_given_derivation;
    option_is_autogenerated_by_CompilerForCAP = is_autogenerated_by_CompilerForCAP;
    
    AddDerivation( CAP_INTERNAL_DERIVATION_GRAPH, target_op, description, used_ops_with_multiples_and_category_getters, func, weight, category_filter, loop_multiplier, category_getters, function_called_before_installation, option_is_with_given_derivation, option_is_autogenerated_by_CompilerForCAP );
    
end ) );

@InstallMethod( DerivationsUsingOperation,
               [ IsDerivedMethodGraph, IsString ],
function( G, op_name )
  return G.derivations_by_used_ops[op_name];
end );

@InstallMethod( DerivationsOfOperation,
               [ IsDerivedMethodGraph, IsString ],
function( G, op_name )
  return G.derivations_by_target[op_name];
end );

@InstallMethod( MakeOperationWeightList,
               [ IsCapCategory, IsDerivedMethodGraph ],
function( C, G )
  local operation_weights, operation_derivations, owl, op_name;
    
    operation_weights = @rec( );
    operation_derivations = @rec( );
    
    for op_name in Operations( G )
        operation_weights[op_name] = infinity;
        operation_derivations[op_name] = fail;
    end;
    
    owl = ObjectifyWithAttributes(
        @rec( operation_weights = operation_weights, operation_derivations = operation_derivations ), TheTypeOfOperationWeightLists,
        DerivationGraph, G,
        CategoryOfOperationWeightList, C
    );
    
    return owl;
    
end );

@InstallMethod( StringGAP,
               [ IsOperationWeightList ],
function( owl )
  return @Concatenation( "operation weight list for ",
                        StringGAP( CategoryOfOperationWeightList( owl ) ) );
end );

@InstallMethod( ViewString,
               [ IsOperationWeightList ],
function( owl )
  return @Concatenation( "<", StringGAP( owl ), ">" );
end );

@InstallMethod( CurrentOperationWeight,
               [ IsOperationWeightList, IsString ],
function( owl, op_name )
  return owl.operation_weights[op_name];
end );

@InstallMethod( OperationWeightUsingDerivation,
               [ IsOperationWeightList, IsDerivedMethod ],
function( owl, d )
  local category, category_operation_weights, weight, operation_weights, operation_weight, x;
    
    category = CategoryOfOperationWeightList( owl );
    category_operation_weights = owl.operation_weights;
    
    weight = AdditionalWeight( d );
    
    for x in UsedOperationsWithMultiplesAndCategoryGetters( d )
        
        if (x[3] == fail)
            
            operation_weights = category_operation_weights;
            
        else
            
            operation_weights = x[3](category).derivations_weight_list.operation_weights;
            
            # the category `x[3](category)` might have been finalized before the operation `x[1]` was added to CAP
            if (@not @IsBound( operation_weights[x[1]] ))
                
                return infinity;
                
            end;
            
        end;
        
        operation_weight = operation_weights[x[1]];
        
        if (operation_weight == infinity)
            
            return infinity;
            
        end;
        
        weight = weight + operation_weight * x[2];
        
    end;
    
    return weight;
    
end );

@InstallMethod( DerivationOfOperation,
               [ IsOperationWeightList, IsString ],
function( owl, op_name )
  return owl.operation_derivations[op_name];
end );

@BindGlobal( "TryToTriggerDerivation", function ( owl, d )
  local new_weight, target, current_weight, current_derivation;
    
    if (@not IsApplicableToCategory( d, CategoryOfOperationWeightList( owl ) ))
        return fail;
    end;
    
    new_weight = OperationWeightUsingDerivation( owl, d );
    
    if (new_weight == infinity)
        return fail;
    end;
    
    target = TargetOperation( d );
    
    current_weight = CurrentOperationWeight( owl, target );
    current_derivation = DerivationOfOperation( owl, target );
    
    if (new_weight < current_weight || (new_weight == current_weight && current_derivation != fail && d.position_in_derivations_by_target < current_derivation.position_in_derivations_by_target))
        
        @Info( DerivationInfo, 1, @Concatenation( "derive(",
                                                StringGAP( new_weight ),
                                                ") ",
                                                target,
                                                ": ",
                                                Description( d ), "\n" ) );
        
        owl.operation_weights[target] = new_weight;
        owl.operation_derivations[target] = d;
        
        # if the weight has not changed, there is no need to re-trigger the chain of derivations
        if (new_weight != current_weight)
            
            TriggerDerivationsUsingOperation( owl, target );
            
        end;
        
    end;
    
end );

@InstallMethod( TriggerDerivationsUsingOperation,
               [ IsOperationWeightList, IsString ],
function( owl, op_name )
  local d;
    
    for d in DerivationsUsingOperation( DerivationGraph( owl ), op_name )
        
        TryToTriggerDerivation( owl, d );
        
    end;
    
end );  

@InstallMethod( Reevaluate,
               [ IsOperationWeightList ],
function( owl )
  local new_weight, op_name, d;
    
    for op_name in Operations( DerivationGraph( owl ) )
        
        for d in DerivationsOfOperation( DerivationGraph( owl ), op_name )
            
            TryToTriggerDerivation( owl, d );
            
        end;
        
    end;
    
end );

@InstallMethod( Saturate,
               [ IsOperationWeightList ],
  function( owl )
    local current_weight_list;

    while true
        current_weight_list = StructuralCopy( owl.operation_weights );
        Reevaluate( owl );
        if (current_weight_list == owl.operation_weights)
            break;
        end;
    end;

end );

@InstallMethod( AddPrimitiveOperation,
               [ IsOperationWeightList, IsString, IsInt ],
function( owl, op_name, new_weight )
    
    owl.operation_weights[op_name] = new_weight;
    @Assert( 0, owl.operation_derivations[op_name] == fail );
    
end );

@InstallMethod( PrintDerivationTree,
               [ IsOperationWeightList, IsString ],
function( owl, op_name )
  local print_node, get_children;
  print_node = function( node )
    local w, mult, op, d;
    mult = node[ 2 ];
    op = node[ 1 ];
    if (op == fail)
      Print( "  ", mult );
      return;
    end;
    w = CurrentOperationWeight( owl, op );
    d = DerivationOfOperation( owl, op );
    if (mult != fail)
      Print( "+ ", mult, " * " );
    end;
    if (w == infinity)
      Print( "(not installed)" );
    else
      Print( "(", w, ")" );
    end;
    Print( " ", op );
    if (w != infinity)
      Print( " " );
      if (d == fail)
        Print( "[primitive]" );
      else
        Print( "[derived:", Description( d ), "]" );
      end;
    end;
  end;
  get_children = function( node )
    local op, d;
    op = node[ 1 ];
    if (op == fail)
      return [];
    end;
    d = DerivationOfOperation( owl, op );
    if (d == fail)
      return [];
    else
      return @Concatenation( [ [ fail, AdditionalWeight( d ) ] ],
                            UsedOperationsWithMultiplesAndCategoryGetters( d ) );
    end;
  end;
  PrintTree( [ op_name, fail ],
             print_node,
             get_children );
end );

@InstallMethod( PrintTree,
               [ IsObject, IsFunction, IsFunction ],
function( root, print_node, get_children )
  PrintTreeRec( root, print_node, get_children, 0 );
end );

@InstallMethod( PrintTreeRec,
               [ IsObject, IsFunction, IsFunction, IsInt ],
function( node, print_node, get_children, level )
  local i, child;
  for i in (1):(level)
    Print( "   " );
  end;
  print_node( node );
  Print( "\n" );
  for child in get_children( node )
    PrintTreeRec( child, print_node, get_children, level + 1 );
  end;
end );

#################################
##
## Final derivations
##
#################################

@InstallValueConst( CAP_INTERNAL_FINAL_DERIVATION_LIST, [ ] );

@InstallGlobalFunction( AddFinalDerivation, @FunctionWithNamedArguments(
  [
    # When compiling categories, a derivation does not cause overhead anymore, so we would like to simply set `Weight` to 0.
    # However, the weight 1 is currently needed to prevent the installation of cyclic derivations.
    [ "Weight", 1 ],
    [ "CategoryFilter", IsCapCategory ],
    [ "WeightLoopMultiple", 2 ],
    [ "CategoryGetters", Immutable( @rec( ) ) ],
    [ "FunctionCalledBeforeInstallation", false ],
  ],
  function( CAP_NAMED_ARGUMENTS, target_op, description, can_compute, cannot_compute, func )
    
    AddFinalDerivationBundle(
        description, can_compute, cannot_compute, [ target_op, can_compute, func ],
        Weight = Weight,
        CategoryFilter = CategoryFilter,
        WeightLoopMultiple = WeightLoopMultiple,
        CategoryGetters = CategoryGetters,
        FunctionCalledBeforeInstallation = FunctionCalledBeforeInstallation
    );
    
end ) );

@InstallGlobalFunction( AddFinalDerivationBundle, @FunctionWithNamedArguments(
  [
    # When compiling categories, a derivation does not cause overhead anymore, so we would like to simply set `Weight` to 0.
    # However, the weight 1 is currently needed to prevent the installation of cyclic derivations.
    [ "Weight", 1 ],
    [ "CategoryFilter", IsCapCategory ],
    [ "WeightLoopMultiple", 2 ],
    [ "CategoryGetters", Immutable( @rec( ) ) ],
    [ "FunctionCalledBeforeInstallation", false ],
  ],
  function( CAP_NAMED_ARGUMENTS, description, can_compute, cannot_compute, additional_functions... )
    local weight, category_filter, loop_multiplier, category_getters, function_called_before_installation, operations_to_install, union_of_collected_lists, derivations, derivation, used_op_names_with_multiples_and_category_getters, dummy_derivation, final_derivation, i, x, current_additional_func;
    
    weight = Weight;
    category_filter = CategoryFilter;
    loop_multiplier = WeightLoopMultiple;
    category_getters = CategoryGetters;
    function_called_before_installation = FunctionCalledBeforeInstallation;
    
    if (IsEmpty( additional_functions ))
        
        Error( "trying to add a final derivation without any functions to install" );
        
    end;
    
    for i in (1):(Length( additional_functions ))
        
        if (!(IsList( additional_functions[i] ) && Length( additional_functions[i] ) == 3))
            
            Error( "additional functions must be given as triples [ <operation>, <preconditions>, <function> ]" );
            
        end;
        
        if (IsList( Last( additional_functions[i] ) ))
            
            Error( "passing lists of functions to `AddFinalDerivation` is not supported anymore" );
            
        end;
        
        if (@not additional_functions[i][1] in cannot_compute)
            
            Print( "WARNING: A final derivation installs ", NameFunction( additional_functions[i][1] ), " but does not list it in its exclude list.\n" );
            
        end;
        
    end;
    
    for x in can_compute
        
        if (Length( x ) < 2 || !(IsFunction( x[1] )) || @not IsInt( x[2] ))
            
            Error( "preconditions must be of the form `[op, mult, getter]`, where `getter` is optional" );
            
        end;
        
        # check that preconditions do not appear in cannot_compute (which in particular includes all operations installed by this final derivation, as checked above)
        if ((Length( x ) == 2 || (Length( x ) == 3 && x[3] == fail)) && x[1] in cannot_compute)
            
            Error( "A final derivation for ", NameFunction( additional_functions[1][1] ), " has precondition ", NameFunction( x[1] ), " which is also in its exclude list.\n" );
            
        end;
        
    end;
    
    if (Length( additional_functions ) == 1 && StartsWith( NameFunction( additional_functions[1][1] ), "IsomorphismFrom" ))
        
        Print( "WARNING: You are installing a final derivation for ", NameFunction( additional_functions[1][1] ), " which does not include its inverse. You should probably use a bundled final derivation to also install its inverse.\n" );
        
    end;
    
    ## Find symbols in functions
    operations_to_install = [ ];
    
    union_of_collected_lists = [ ];
    
    derivations = [ ];
    
    for current_additional_func in additional_functions
        
        derivation = CreateDerivation(
            NameFunction( current_additional_func[1] ),
            @Concatenation( description, " (final derivation)" ),
            current_additional_func[2],
            current_additional_func[3],
            weight,
            category_filter,
            loop_multiplier,
            category_getters
        );
        
        Add( derivations, derivation );
        
        used_op_names_with_multiples_and_category_getters = UsedOperationsWithMultiplesAndCategoryGetters( derivation );
        
        # Operations may use operations from the same final derivation as long as the latter are installed before the former.
        # In this case, the used operations are no preconditions and thus should not go into union_of_collected_lists.
        used_op_names_with_multiples_and_category_getters = Filtered( used_op_names_with_multiples_and_category_getters, x -> @not x[1] in operations_to_install );
        
        Add( operations_to_install, NameFunction( current_additional_func[1] ) );
        
        union_of_collected_lists = CAP_INTERNAL_MERGE_PRECONDITIONS_LIST( union_of_collected_lists, used_op_names_with_multiples_and_category_getters );
        
    end;
    
    # only used to check if we can install all the derivations in `derivations`
    dummy_derivation = CreateDerivation(
        "internal dummy function of a final derivation",
        "dummy derivation",
        can_compute,
        ReturnTrue,
        1,
        category_filter,
        loop_multiplier,
        category_getters
    );
    
    used_op_names_with_multiples_and_category_getters = UsedOperationsWithMultiplesAndCategoryGetters( dummy_derivation );
    
    if (Length( union_of_collected_lists ) != Length( used_op_names_with_multiples_and_category_getters ) || @not ForAll( union_of_collected_lists, c -> c in used_op_names_with_multiples_and_category_getters ))
        
        used_op_names_with_multiples_and_category_getters = ShallowCopy( used_op_names_with_multiples_and_category_getters );
        
        SortBy( used_op_names_with_multiples_and_category_getters, x -> x[1] );
        SortBy( union_of_collected_lists, x -> x[1] );
        
        Print(
            "WARNING: You have installed a final derivation for ", TargetOperation( derivations[1] ), " with preconditions ", used_op_names_with_multiples_and_category_getters,
            " but the following list of preconditions was expected: ", union_of_collected_lists, ".\n",
            "If this is a bug in the automated detection, please report it.\n"
        );
        
    end;
    
    final_derivation = @rec(
        dummy_derivation = dummy_derivation,
        cannot_compute = List( cannot_compute, x -> NameFunction( x ) ),
        derivations = derivations,
        function_called_before_installation = function_called_before_installation,
    );
    
    Add( CAP_INTERNAL_FINAL_DERIVATION_LIST, final_derivation );
    
end ) );

#################################
##
## Installing derivations
##
#################################

@InstallGlobalFunction( InstallDerivations, function( category )
  local weight_list, derivation_list, current_install, current_final_derivation, op_name, new_weight, current_weight, i, derivation, operation;
    
    weight_list = MakeOperationWeightList( category, CAP_INTERNAL_DERIVATION_GRAPH );
    
    category.derivations_weight_list = weight_list;
    
    for op_name in RecNames( category.operations )
        
        @Assert( 0, category.operations[op_name].type in [ "primitive_installation", "precompiled_derivation" ] );
        
        AddPrimitiveOperation( weight_list, op_name, category.operations[op_name].weight );
        
    end;
    
    # Trigger ordinary derivations, but do not install them yet:
    # While triggering derivations, cheaper derivations can become available, but we do not want to overwrite methods.
    
    TriggerDerivationsUsingOperation( weight_list, "none" );
    
    for op_name in SortedList( RecNames( weight_list.operation_weights ) )
        
        if (weight_list.operation_weights[op_name] != infinity && weight_list.operation_derivations[op_name] == fail)
            
            @Info( DerivationInfo, 1, @Concatenation( "add(",
                                                    StringGAP( weight_list.operation_weights[op_name] ),
                                                    ") ",
                                                    op_name,
                                                    ": primitive installation\n" ) );
            
            TriggerDerivationsUsingOperation( weight_list, op_name );
            
        end;
        
    end;
    
    # Trigger and install final derivations
    
    derivation_list = ShallowCopy( CAP_INTERNAL_FINAL_DERIVATION_LIST );
    
    while true
        
        current_install = fail;
        
        for i in (1):(Length( derivation_list ))
            
            current_final_derivation = derivation_list[ i ];
            
            # check if all conditions for installing the final derivation are met
            
            if (@not IsApplicableToCategory( current_final_derivation.dummy_derivation, category ))
                
                continue;
                
            end;
            
            if (ForAny( current_final_derivation.cannot_compute, operation_name -> CurrentOperationWeight( weight_list, operation_name ) < infinity ))
                
                continue;
                
            end;
            
            if (OperationWeightUsingDerivation( weight_list, current_final_derivation.dummy_derivation ) == infinity)
                
                continue;
                
            end;
            
            # if we get here, everything matched
            current_install = i;
            break;
            
        end;
        
        if (current_install == fail)
            
            break;
            
        else
            
            current_final_derivation = Remove( derivation_list, current_install );
            
            ## call function before adding the method
            
            if (current_final_derivation.function_called_before_installation != false)
                
                current_final_derivation.function_called_before_installation( category );
                
            end;
            
            for derivation in current_final_derivation.derivations
                
                op_name = TargetOperation( derivation );
                new_weight = OperationWeightUsingDerivation( weight_list, derivation );
                current_weight = CurrentOperationWeight( weight_list, op_name );
                
                @Assert( 0, new_weight != infinity );
                
                # When installing a final derivation bundle, the installation of the first operations in the bundle
                # might trigger (normal) derivations of later operations it the bundle, which might be cheaper)
                # the derivations provided in the bundle.
                if (new_weight <= current_weight)
                    
                    @Info( DerivationInfo, 1, @Concatenation( "derive(",
                                                            StringGAP( new_weight ),
                                                            ") ",
                                                            op_name,
                                                            ": ",
                                                            Description( derivation ), "\n" ) );
                    
                    weight_list.operation_weights[op_name] = new_weight;
                    weight_list.operation_derivations[op_name] = fail;
                    
                    InstallDerivationForCategory( derivation, new_weight, category; IsFinalDerivation = true );
                    
                    # if the weight has not changed, there is no need to re-trigger the chain of derivations
                    if (new_weight != current_weight)
                        
                        TriggerDerivationsUsingOperation( weight_list, op_name );
                        
                    end;
                    
                end;
                
            end;
            
        end;
        
    end;
    
    # Actually install ordinary derivations
    
    for operation in Operations( DerivationGraph( weight_list ) )
        
        if (DerivationOfOperation( weight_list, operation ) != fail)
            
            InstallDerivationForCategory( DerivationOfOperation( weight_list, operation ), CurrentOperationWeight( weight_list, operation ), category );
            
        end;
        
    end;
    
end );

#################################
##
## Some print functions
##
#################################

##
@InstallGlobalFunction( InstalledMethodsOfCategory,
  
  function( cell )
    local weight_list, list_of_methods, i, current_weight, can_compute, cannot_compute;
    
    if (IsCapCategory( cell ))
        weight_list = cell.derivations_weight_list;
    elseif (IsCapCategoryCell( cell ))
        weight_list = CapCategory( cell ).derivations_weight_list;
    else
        Error( "Input must be a category or a cell" );
    end;
    
    list_of_methods = Operations( CAP_INTERNAL_DERIVATION_GRAPH );
    
    list_of_methods = AsSortedList( list_of_methods );
    
    can_compute = [ ];
    cannot_compute = [ ];
    
    for i in list_of_methods
        
        current_weight = CurrentOperationWeight( weight_list, i );
        
        if (current_weight < infinity)
            Add( can_compute, [ i, current_weight ] );
        else
            Add( cannot_compute, i );
        end;
        
    end;
    
    Print( "Can do the following basic methods at the moment:\n" );
    
    for i in can_compute
        Print( "+ ", i[ 1 ], ", weight ", StringGAP( i[ 2 ] ), "\n" );
    end;
    
    Print( "\nThe following is still missing:\n" );
    
    for i in cannot_compute
        Print( "- ", i, "\n" );
    end;
    
    Print( "\nPlease use DerivationsOfMethodByCategory( <category>, <name> ) to get\n",
           "information about how to add the missing methods\n" );
    
end );

##
@InstallGlobalFunction( DerivationsOfMethodByCategory,
  
  function( category, name )
    local current_derivation, currently_installed_func, weight_list, category_getter_string, possible_derivations, category_filter, weight, found, x, final_derivation;
    
    if (IsFunction( name ))
        name = NameFunction( name );
    end;
    
    if (@not IsString( name ))
        Error( "Usage is <category>,<string> or <category>,<CAP operation>\n" );
        return;
    end;
    
    if (@not @IsBound( CAP_INTERNAL_METHOD_NAME_RECORD[name] ))
        Error( name, " is not the name of a CAP operation." );
        return;
    end;
    
    if (CanCompute( category, name ))
    
        Print( Name( category ), " can already compute ", TextAttr.b4, name, TextAttr.reset, " with weight " , OperationWeight( category, name ), ".\n" );
        
        if (category.operations[name].type == "primitive_installation")
            
            Print( "It was installed primitively.\n" );
            
        elseif (category.operations[name].type == "final_derivation")
            
            Print( "It was installed as a final derivation.\n" );
            
        elseif (category.operations[name].type == "precompiled_derivation")
            
            Print( "It was installed as a precompiled derivation.\n" );
            
        elseif (category.operations[name].type == "ordinary_derivation")
            
            current_derivation = DerivationOfOperation( category.derivations_weight_list, name );
            
            Print( "It was derived by ", TextAttr.b3, Description( current_derivation ), TextAttr.reset, " using \n" );
            
            for x in UsedOperationsWithMultiplesAndCategoryGetters( current_derivation )
                
                if (x[3] == fail)
                    
                    weight_list = category.derivations_weight_list;
                    category_getter_string = "";
                    
                else
                    
                    weight_list = x[3](category).derivations_weight_list;
                    category_getter_string = @Concatenation( " in category obtained by applying ", StringGAP( x[3] ) );
                    
                end;
                
                Print( "* ", TextAttr.b2, x[1], TextAttr.reset, " (", x[2], "x)", category_getter_string );
                Print( " installed with weight ", StringGAP( CurrentOperationWeight( weight_list, x[1] ) ) );
                Print( "\n" );
                
            end;
            
            @Assert( 0, IsIdenticalObj( category.operations[name].func, DerivationFunction( current_derivation ) ) );
            
        else
            
            Error( "this should never happen" );
            
        end;
        
        currently_installed_func = category.operations[name].func;
        
        Print( "\nThe following function was installed for this operation:\n\n" );
        Display( currently_installed_func );
        Print( "\n" );
        Print( "Source: ", FilenameFunc( currently_installed_func ), ":", StartlineFunc( currently_installed_func ), "\n" );
        Print( "\n" );
        Print( "#######\n\n" );
        
    else
        
        Print( TextAttr.b4, name, TextAttr.reset, " is currently not installed for ", Name( category ), ".\n\n" );
        
    end;
    
    Print( "Possible derivations are:\n\n" );
    
    possible_derivations = List( DerivationsOfOperation( CAP_INTERNAL_DERIVATION_GRAPH, name ), d -> @rec( derivation = d ) );
    
    for final_derivation in CAP_INTERNAL_FINAL_DERIVATION_LIST
        
        for current_derivation in final_derivation.derivations
            
            if (TargetOperation( current_derivation ) == name)
                
                Add( possible_derivations, @rec(
                    derivation = current_derivation,
                    can_compute = UsedOperationsWithMultiplesAndCategoryGetters( final_derivation.dummy_derivation ),
                    cannot_compute = final_derivation.cannot_compute,
                ) );
                
            end;
            
        end;
        
    end;
    
    for current_derivation in possible_derivations
        
        category_filter = CategoryFilter( current_derivation.derivation );
        
        # `SizeScreen()[1] - 3` is taken from the code for package banners
        Print( ListWithIdenticalEntries( SizeScreen()[1] - 3, '-' ), "\n" );
        if (category_filter( category ))
            Print( TextAttr.b4, name, TextAttr.reset, " can be derived by\n" );
        else
            if (IsFilter( category_filter ))
                Print( "If ", Name( category ), " would be ", JoinStringsWithSeparator( Filtered( NamesFilter( category_filter ), name -> @not StartsWith( name, "Has" ) ), " and " ) );
            else
                Print( "If ", Name( category ), " would fulfill the conditions given by\n\n" );
                Display( category_filter );
            end;
            Print( "\nthen ", TextAttr.b4, name, TextAttr.reset, " could be derived by\n" );
        end;
        
        for x in UsedOperationsWithMultiplesAndCategoryGetters( current_derivation.derivation )
            
            if (x[3] == fail)
                
                if (CanCompute( category, x[1] ))
                    
                    weight = OperationWeight( category, x[1] );
                    
                else
                    
                    weight = infinity;
                    
                end;
                
                category_getter_string = "";
                
            else
                
                if (category_filter( category ) && CanCompute( x[3](category), x[1] ))
                    
                    weight = OperationWeight( x[3](category), x[1] );
                    
                else
                    
                    weight = infinity;
                    
                end;
                
                category_getter_string = @Concatenation( " in the category obtained by applying ", StringGAP( x[3] ) );
                
            end;
            
            if (weight < infinity)
                Print( "* ", TextAttr.b2, x[1], TextAttr.reset, " (", x[2], "x)", category_getter_string, ", (already installed with weight ", weight,")" );
            else
                Print( "* ", TextAttr.b1, x[1], TextAttr.reset, " (", x[2], "x)", category_getter_string );
            end;
            
            Print( "\n" );
            
        end;
        
        Print( "with additional weight ", AdditionalWeight( current_derivation.derivation ) );
        
        @Assert( 0, @IsBound( current_derivation.can_compute ) == @IsBound( current_derivation.cannot_compute ) );
        
        if (@IsBound( current_derivation.can_compute ))
            
            Print( "\n\nas a final derivation\nif the following additional operations could be computed\n" );
            
            found = false;
            
            for x in current_derivation.can_compute
                
                if (x[3] == fail)
                    
                    if (CanCompute( category, x[1] ))
                        
                        weight = OperationWeight( category, x[1] );
                        
                    else
                        
                        weight = infinity;
                        
                    end;
                    
                    category_getter_string = "";
                    
                else
                    
                    if (category_filter( category ) && CanCompute( x[3](category), x[1] ))
                        
                        weight = OperationWeight( x[3](category), x[1] );
                        
                    else
                        
                        weight = infinity;
                        
                    end;
                
                    category_getter_string = @Concatenation( " in the category obtained by applying ", StringGAP( x[3] ) );
                    
                end;
                
                if (weight == infinity)
                    
                    Print( "* ", x[1], category_getter_string, "\n" );
                    found = true;
                    
                end;
                
            end;
            
            if (@not found)
                
                Print( "(none)\n" );
                
            end;
            
            Print( "\nand the following additional operations could not be computed\n" );
            
            found = false;
            
            for x in current_derivation.cannot_compute
                
                if (CanCompute( category, x ))
                    
                    Print( "* ", x, "\n" );
                    found = true;
                    
                end;
                
            end;
            
            if (@not found)
                
                Print( "(none)\n" );
                
            end;
            
        else
            
            Print( ".\n" );
            
        end;
        
        Print( "\n" );
        
    end;
    
end );
