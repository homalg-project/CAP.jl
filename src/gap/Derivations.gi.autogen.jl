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
@BindGlobal( "TheFamilyOfStringMinHeaps",
            NewFamily( "TheFamilyOfStringMinHeaps" ) );

@BindGlobal( "TheTypeOfDerivedMethods", NewType( TheFamilyOfDerivations, IsDerivedMethod ) );
@BindGlobal( "TheTypeOfDerivationsGraphs", NewType( TheFamilyOfDerivationGraphs, IsDerivedMethodGraph ) );
@BindGlobal( "TheTypeOfOperationWeightLists", NewType( TheFamilyOfOperationWeightLists, IsOperationWeightList ) );
@BindGlobal( "TheTypeOfStringMinHeaps", NewType( TheFamilyOfStringMinHeaps, IsStringMinHeap ) );

@InstallGlobalFunction( "ActivateDerivationInfo",
  function( )
    SetInfoLevel( DerivationInfo, 1 );
end );

@InstallGlobalFunction( "DeactivateDerivationInfo",
  function( )
    SetInfoLevel( DerivationInfo, 0 );
end );

InstallMethod( @__MODULE__,  MakeDerivation,
               [ IsString, IsFunction, IsDenseList, IsPosInt, IsFunction, IsFunction ],
               
function( name, target_op, used_op_names_with_multiples_and_category_getters, weight, func, category_filter )
  local wrapped_category_filter;
    
    if PositionSublist( string( category_filter ), "CanCompute" ) != fail
        
        Print( "WARNING: The CategoryFilter of a derivation for ", NameFunction( target_op ), " uses `CanCompute`. Please register all preconditions explicitly.\n" );
        
    end;
    
    if NumberArgumentsFunction( category_filter ) == 0 || NumberArgumentsFunction( category_filter ) > 1
        
        Error( "the CategoryFilter of a derivation must accept exactly one argument" );
        
    end;
    
    if ForAny( used_op_names_with_multiples_and_category_getters, x -> x[3] != fail ) && category_filter == IsCapCategory
        
        Print( "WARNING: A derivation for ", NameFunction( target_op ), " depends on other categories (e.g. RangeCategoryOfHomomorphismStructure) but does no test via the CategoryFilter if the other categories are available (e.g. by testing HasRangeCategoryOfHomomorphismStructure).\n" );
        
    end;
    
    if IsProperty( category_filter )
        
        wrapped_category_filter = cat -> Tester( category_filter )( cat ) && category_filter( cat );
        
    else
        
        wrapped_category_filter = category_filter;
        
    end;
    
    return ObjectifyWithAttributes(
        rec( ), TheTypeOfDerivedMethods,
        DerivationName, name,
        DerivationWeight, weight,
        DerivationFunction, func,
        CategoryFilter, wrapped_category_filter,
        TargetOperation, NameFunction( target_op ),
        UsedOperationsWithMultiplesAndCategoryGetters, used_op_names_with_multiples_and_category_getters
    );
    
end );

InstallMethod( @__MODULE__,  String,
               [ IsDerivedMethod ],
function( d )
  return Concatenation( "derivation ", DerivationName( d ),
                        " of operation ", TargetOperation( d ) );
end );

InstallMethod( @__MODULE__,  ViewString,
               [ IsDerivedMethod ],
function( d )
  return Concatenation( "<", string( d ), ">" );
end );

InstallMethod( @__MODULE__,  IsApplicableToCategory,
               [ IsDerivedMethod, IsCapCategory ],
function( d, C )
  return CategoryFilter( d )( C );
end );

InstallMethod( @__MODULE__,  InstallDerivationForCategory,
               [ IsDerivedMethod, IsPosInt, IsCapCategory ],
function( d, weight, C )
  local method_name, func, add_method, add_name, general_filter_list,
        installation_name, nr_arguments, cache_name, current_filters, current_implementation,
        function_called_before_installation;
  
  Info( DerivationInfo, 1, Concatenation( "install(",
                                          string( weight ),
                                          ") ",
                                          TargetOperation( d ),
                                          ": ",
                                          DerivationName( d ), "\n" ) );
  
  method_name = TargetOperation( d );
  func = DerivationFunction( d );
  add_name = Concatenation( "Add", method_name );
  add_method = ValueGlobal( add_name );
  
  if HasFunctionCalledBeforeInstallation( d )
      
      FunctionCalledBeforeInstallation( d )( C );
      
  end;
  
  # use the add method with signature IsCapCategory, IsList, IsInt to avoid
  # the convenience for AddZeroObject etc.
  add_method( C, [ pair( func, [ ] ) ], weight; IsDerivation = true );
  
end );

InstallMethod( @__MODULE__,  DerivationResultWeight,
               [ IsDerivedMethod, IsDenseList ],
function( d, op_weights )
  local w, used_op_multiples, i, op_w, mult;
  Display( "WARNING: DerivationResultWeight is deprecated && will !be supported after 2023.08.26.\n" );
  w = DerivationWeight( d );
  used_op_multiples = UsedOperationsWithMultiplesAndCategoryGetters( d );
  for i in (1):(Length( used_op_multiples ))
    op_w = op_weights[ i ];
    mult = used_op_multiples[ i ][ 2 ];
    if op_w == Inf
      return Inf;
    end;
    w = w + op_w * mult;
  end;
  return w;
end );

InstallMethod( @__MODULE__,  MakeDerivationGraph,
               [ IsDenseList ],
function( operations )
  local G, op_name;
  G = rec( derivations_by_target = rec(),
              derivations_by_used_ops = rec() );
  G = ObjectifyWithAttributes( G, TheTypeOfDerivationsGraphs );
  
  SetOperations( G, operations );
  
  for op_name in operations
    G.derivations_by_target[op_name] = [];
    G.derivations_by_used_ops[op_name] = [];
  end;
  
  # derivations !using any operations
  G.derivations_by_used_ops.none = [];
  
  return G;
end );

InstallMethod( @__MODULE__,  AddOperationsToDerivationGraph,
               [ IsDerivedMethodGraph, IsDenseList ],
               
  function( graph, operations )
    local op_name;
    
    Append( Operations( graph ), operations );
    
    for op_name in operations
        
        graph.derivations_by_target[op_name] = [];
        graph.derivations_by_used_ops[op_name] = [];
        
    end;
    
end );

InstallMethod( @__MODULE__,  String,
               [ IsDerivedMethodGraph ],
function( G )
  return "derivation graph";
end );

InstallMethod( @__MODULE__,  ViewString,
               [ IsDerivedMethodGraph ],
function( G )
  return Concatenation( "<", string( G ), ">" );
end );

InstallMethod( @__MODULE__,  AddDerivation,
               [ IsDerivedMethodGraph, IsDerivedMethod ],
function( G, d )
  local method_name, filter_list, number_of_proposed_arguments, current_function_argument_number, target_op, x;
  
  if IsIdenticalObj( G, CAP_INTERNAL_DERIVATION_GRAPH )
    
    method_name = TargetOperation( d );
    
    if !IsBound( CAP_INTERNAL_METHOD_NAME_RECORD[method_name] )
        
        Error( "trying to add a derivation to CAP_INTERNAL_DERIVATION_GRAPH for a method !in CAP_INTERNAL_METHOD_NAME_RECORD" );
        
    end;
    
    filter_list = CAP_INTERNAL_METHOD_NAME_RECORD[method_name].filter_list;
    
    number_of_proposed_arguments = Length( filter_list );
    
    current_function_argument_number = NumberArgumentsFunction( DerivationFunction( d ) );
    
    if current_function_argument_number >= 0 && current_function_argument_number != number_of_proposed_arguments
        Error( "While adding a derivation for ", method_name, ": given function has ", string( current_function_argument_number ),
               " arguments but should have ", string( number_of_proposed_arguments ) );
    end;
    
  end;
  
  target_op = TargetOperation( d );
  
  Add( G.derivations_by_target[target_op], d );
  for x in UsedOperationsWithMultiplesAndCategoryGetters( d )
    # We add all operations, even those with category getters: In case the category getter
    # returns the category itself, this allows to recursively trigger derivations correctly.
    Add( G.derivations_by_used_ops[x[1]], d );
  end;
  
  if IsEmpty( UsedOperationsWithMultiplesAndCategoryGetters( d ) )
    
    Add( G.derivations_by_used_ops.none, d );
    
  end;
  
end );

InstallMethod( @__MODULE__,  AddDerivation,
               [ IsDerivedMethodGraph, IsFunction, IsFunction ],
               
  function( graph, target_op, func )
    
    AddDerivation( graph, target_op, fail, func );
    
end );

# Contrary to the documentation, for internal code we allow used_ops_with_multiples_and_category_getters to be equal to fail
# to distinguish the case of no preconditions given
InstallOtherMethod( AddDerivation,
               [ IsDerivedMethodGraph, IsFunction, IsObject, IsFunction ],
               
  function( graph, target_op, used_ops_with_multiples_and_category_getters, func )
    local weight, category_filter, description, loop_multiplier, category_getters, function_called_before_installation, operations_in_graph, collected_list, used_op_names_with_multiples_and_category_getters, derivation, x;
    
    Assert( 0, used_ops_with_multiples_and_category_getters == fail || IsList( used_ops_with_multiples_and_category_getters ) );
    
    weight = CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "Weight", 1 );
    category_filter = CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "CategoryFilter", IsCapCategory );
    description = CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "Description", "" );
    loop_multiplier = CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "WeightLoopMultiple", 2 );
    category_getters = CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "CategoryGetters", rec( ) );
    function_called_before_installation = CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "FunctionCalledBeforeInstallation", false );
    
    ## get used ops
    operations_in_graph = Operations( graph );
    
    used_op_names_with_multiples_and_category_getters = fail;
    
    #= comment for Julia
    collected_list = CAP_INTERNAL_FIND_APPEARANCE_OF_SYMBOL_IN_FUNCTION( func, operations_in_graph, loop_multiplier, CAP_INTERNAL_METHOD_RECORD_REPLACEMENTS, category_getters );
    
    if used_ops_with_multiples_and_category_getters == fail
        
        used_op_names_with_multiples_and_category_getters = collected_list;
        
    end;
    # =#
    
    if used_ops_with_multiples_and_category_getters != fail
        
        used_op_names_with_multiples_and_category_getters = [ ];
        
        for x in used_ops_with_multiples_and_category_getters
            
            if Length( x ) < 2 || !IsFunction( x[1] ) || !IsInt( x[2] )
                
                Error( "preconditions must be of the form `[op, mult, getter]`, where `getter` is optional" );
                
            end;
            
            if (Length( x ) == 2 || (Length( x ) == 3 && x[3] == fail)) && x[1] == target_op
                
                Error( "A derivation for ", NameFunction( target_op ), " has itself as a precondition. This is !supported because we can!compute a well-defined weight.\n" );
                
            end;
            
            if Length( x ) == 2
                
                Add( used_op_names_with_multiples_and_category_getters, [ NameFunction( x[1] ), x[2], fail ] );
                
            elseif Length( x ) == 3
                
                if x != fail && !(IsFunction( x[3] ) && NumberArgumentsFunction( x[3] ) == 1)
                    
                    Error( "the category getter must be a single-argument function" );
                    
                end;
                
                Add( used_op_names_with_multiples_and_category_getters, [ NameFunction( x[1] ), x[2], x[3] ] );
                
            else
                
                Error( "The list of preconditions must be a list of pairs || triples." );
                
            end;
            
        end;
        
        #= comment for Julia
        if Length( collected_list ) != Length( used_op_names_with_multiples_and_category_getters ) || !ForAll( collected_list, c -> c ⥉ used_op_names_with_multiples_and_category_getters )
            
            SortBy( used_op_names_with_multiples_and_category_getters, x -> x[1] );
            SortBy( collected_list, x -> x[1] );
            
            Print(
                "WARNING: You have installed a derivation for ", NameFunction( target_op ), " with preconditions ", used_op_names_with_multiples_and_category_getters,
                " but the automated detection has detected the following list of preconditions: ", collected_list, ".\n",
                "If this is a bug ⥉ the automated detection, please report it.\n"
            );
            
        end;
        # =#
        
    end;
    
    if used_op_names_with_multiples_and_category_getters == fail
        
        return;
        
    end;
    
    derivation = MakeDerivation( description,
                                  target_op,
                                  used_op_names_with_multiples_and_category_getters,
                                  weight,
                                  func,
                                  category_filter );
    
    if function_called_before_installation != false
        
        SetFunctionCalledBeforeInstallation( derivation, function_called_before_installation );
        
    end;
    
    AddDerivation( graph, derivation );
    
end );

InstallMethod( @__MODULE__,  AddDerivation,
               [ IsDerivedMethodGraph, IsFunction, IsDenseList ],
               
  function( graph, target_op, implementations_with_extra_filters )
    
    Error( "passing a list of functions to `AddDerivation` is !supported anymore" );
    
end );

InstallMethod( @__MODULE__,  AddDerivation,
               [ IsDerivedMethodGraph, IsFunction, IsDenseList, IsDenseList ],
               
  function( graph, target_op, used_ops_with_multiples, implementations_with_extra_filters )
    
    Error( "passing a list of functions to `AddDerivation` is !supported anymore" );
    
end );

@InstallGlobalFunction( AddDerivationToCAP,
  
  function( arg... )
    local list;
    
    list = Concatenation( [ CAP_INTERNAL_DERIVATION_GRAPH ], arg );
    
    CallFuncList( AddDerivation, list );
    
end );

@InstallGlobalFunction( AddWithGivenDerivationPairToCAP,
  
  function( target_op, without_given_func, with_given_func )
    local without_given_name, with_given_name;
    
    without_given_name = NameFunction( target_op );
    
    with_given_name = CAP_INTERNAL_METHOD_NAME_RECORD[without_given_name].with_given_without_given_name_pair[2];
    
    AddDerivationToCAP( target_op, without_given_func );
    AddDerivationToCAP( ValueGlobal( with_given_name ), with_given_func );
    
end );

InstallMethod( @__MODULE__,  DerivationsUsingOperation,
               [ IsDerivedMethodGraph, IsString ],
function( G, op_name )
  return G.derivations_by_used_ops[op_name];
end );

InstallMethod( @__MODULE__,  DerivationsOfOperation,
               [ IsDerivedMethodGraph, IsString ],
function( G, op_name )
  return G.derivations_by_target[op_name];
end );

InstallMethod( @__MODULE__,  MakeOperationWeightList,
               [ IsCapCategory, IsDerivedMethodGraph ],
function( C, G )
  local operation_weights, operation_derivations, owl, op_name;
    
    operation_weights = rec( );
    operation_derivations = rec( );
    
    for op_name in Operations( G )
        operation_weights[op_name] = Inf;
        operation_derivations[op_name] = fail;
    end;
    
    owl = ObjectifyWithAttributes(
        rec( operation_weights = operation_weights, operation_derivations = operation_derivations ), TheTypeOfOperationWeightLists,
        DerivationGraph, G,
        CategoryOfOperationWeightList, C
    );
    
    return owl;
    
end );

InstallMethod( @__MODULE__,  String,
               [ IsOperationWeightList ],
function( owl )
  return Concatenation( "operation weight list for ",
                        string( CategoryOfOperationWeightList( owl ) ) );
end );

InstallMethod( @__MODULE__,  ViewString,
               [ IsOperationWeightList ],
function( owl )
  return Concatenation( "<", string( owl ), ">" );
end );

InstallMethod( @__MODULE__,  CurrentOperationWeight,
               [ IsOperationWeightList, IsString ],
function( owl, op_name )
  if IsBound( owl.operation_weights[op_name] )
      return owl.operation_weights[op_name];
  end;
  return Inf;
end );

InstallMethod( @__MODULE__,  OperationWeightUsingDerivation,
               [ IsOperationWeightList, IsDerivedMethod ],
function( owl, d )
  local category, category_operation_weights, weight, operation_weights, operation_name, operation_weight, x;
    
    category = CategoryOfOperationWeightList( owl );
    category_operation_weights = owl.operation_weights;
    
    weight = DerivationWeight( d );
    
    for x in UsedOperationsWithMultiplesAndCategoryGetters( d )
        
        if x[3] == fail
            
            operation_weights = category_operation_weights;
            
        else
            
            operation_weights = x[3](category).derivations_weight_list.operation_weights;
            
        end;
        
        operation_name = x[1];
        
        if !IsBound( operation_weights[operation_name] )
            
            return Inf;
            
        end;
        
        operation_weight = operation_weights[operation_name];
        
        if operation_weight == Inf
            
            return Inf;
            
        end;
        
        weight = weight + operation_weight * x[2];
        
    end;
    
    return weight;
    
end );

InstallMethod( @__MODULE__,  DerivationOfOperation,
               [ IsOperationWeightList, IsString ],
function( owl, op_name )
  return owl.operation_derivations[op_name];
end );

@BindGlobal( "TryToInstallDerivation", function ( owl, d )
  local new_weight, target, current_weight, current_derivation, derivations_of_target, new_pos, current_pos;
    
    if !IsApplicableToCategory( d, CategoryOfOperationWeightList( owl ) )
        return fail;
    end;
    
    new_weight = OperationWeightUsingDerivation( owl, d );
    
    if new_weight == Inf
        return fail;
    end;
    
    target = TargetOperation( d );
    
    current_weight = CurrentOperationWeight( owl, target );
    current_derivation = DerivationOfOperation( owl, target );
    
    if current_derivation != fail
        
        derivations_of_target = DerivationsOfOperation( DerivationGraph( owl ), target );
        
        new_pos = PositionProperty( derivations_of_target, x -> IsIdenticalObj( x, d ) );
        current_pos = PositionProperty( derivations_of_target, x -> IsIdenticalObj( x, current_derivation ) );
        
        Assert( 0, new_pos != fail );
        Assert( 0, current_pos != fail );
        
    end;

    if new_weight < current_weight || (new_weight == current_weight && current_derivation != fail && new_pos < current_pos)
        
        if !IsIdenticalObj( current_derivation, d )
            
            InstallDerivationForCategory( d, new_weight, CategoryOfOperationWeightList( owl ) );
            
        end;
        
        owl.operation_weights[target] = new_weight;
        owl.operation_derivations[target] = d;
        
        return new_weight;
        
    else
        
        return fail;
        
    end;
    
end );

InstallMethod( @__MODULE__,  InstallDerivationsUsingOperation,
               [ IsOperationWeightList, IsString ],
function( owl, op_name )
  local Q, derivations_to_install, node, new_weight, target, d;
    
    Q = StringMinHeap();
    Add( Q, op_name, 0 );
    
    while !IsEmptyHeap( Q )
        
        node = ExtractMin( Q );
        
        op_name = node[ 1 ];
        
        for d in DerivationsUsingOperation( DerivationGraph( owl ), op_name )
            
            new_weight = TryToInstallDerivation( owl, d );
            
            if new_weight != fail
                
                target = TargetOperation( d );
                
                if Contains( Q, target )
                    
                    DecreaseKey( Q, target, new_weight );
                    
                else
                    
                    Add( Q, target, new_weight );
                    
                end;
                
            end;
            
        end;
        
    end;
    
end );  

InstallMethod( @__MODULE__,  Reevaluate,
               [ IsOperationWeightList ],
function( owl )
  local new_weight, op_name, d;
    
    for op_name in Operations( DerivationGraph( owl ) )
        
        for d in DerivationsOfOperation( DerivationGraph( owl ), op_name )
            
            new_weight = TryToInstallDerivation( owl, d );
            
            if new_weight != fail
                
                InstallDerivationsUsingOperation( owl, TargetOperation( d ) );
                
            end;
            
        end;
        
    end;
    
end );

InstallMethod( @__MODULE__,  Saturate,
               [ IsOperationWeightList ],
  function( owl )
    local current_weight_list;

    while true
        current_weight_list = StructuralCopy( owl.operation_weights );
        Reevaluate( owl );
        if current_weight_list == owl.operation_weights
            break;
        end;
    end;

end );

InstallMethod( @__MODULE__,  AddPrimitiveOperation,
               [ IsOperationWeightList, IsString, IsInt ],
function( owl, op_name, weight )
    
    Info( DerivationInfo, 1, Concatenation( "install(",
                                  string( weight ),
                                  ") ",
                                  op_name,
                                  ": primitive installation\n" ) );
    
    owl.operation_weights[op_name] = weight;
    owl.operation_derivations[op_name] = fail;
    
    InstallDerivationsUsingOperation( owl, op_name );
    
end );

InstallMethod( @__MODULE__,  PrintDerivationTree,
               [ IsOperationWeightList, IsString ],
function( owl, op_name )
  local print_node, get_children;
  print_node = function( node )
    local w, mult, op, d;
    mult = node[ 2 ];
    op = node[ 1 ];
    if op == fail
      Print( "  ", mult );
      return;
    end;
    w = CurrentOperationWeight( owl, op );
    d = DerivationOfOperation( owl, op );
    if mult != fail
      Print( "+ ", mult, " * " );
    end;
    if w == Inf
      Print( "(!installed)" );
    else
      Print( "(", w, ")" );
    end;
    Print( " ", op );
    if w != Inf
      Print( " " );
      if d == fail
        Print( "[primitive]" );
      else
        Print( "[derived:", DerivationName( d ), "]" );
      end;
    end;
  end;
  get_children = function( node )
    local op, d;
    op = node[ 1 ];
    if op == fail
      return [];
    end;
    d = DerivationOfOperation( owl, op );
    if d == fail
      return [];
    else
      return Concatenation( [ [ fail, DerivationWeight( d ) ] ],
                            UsedOperationsWithMultiplesAndCategoryGetters( d ) );
    end;
  end;
  PrintTree( [ op_name, fail ],
             print_node,
             get_children );
end );


@InstallGlobalFunction( StringMinHeap,
function()
  return Objectify( TheTypeOfStringMinHeaps,
                    rec( key = function(n) return n[2]; end,
                         str = function(n) return n[1]; end,
                         array = [],
                         node_indices = rec() ) );
end );

InstallMethod( @__MODULE__,  String,
               [ IsStringMinHeap ],
function( H )
  return Concatenation( "min heap for strings, with size ",
                        string( HeapSize( H ) ) );
end );

InstallMethod( @__MODULE__,  ViewString,
               [ IsStringMinHeap ],
function( H )
  return Concatenation( "<", string( H ), ">" );
end );

InstallMethod( @__MODULE__,  HeapSize,
               [ IsStringMinHeap ],
function( H )
  return Length( H.array );
end );

InstallMethod( @__MODULE__,  Add,
               [ IsStringMinHeap, IsString, IsInt ],
function( H, string, key )
  local array;
  array = H.array;
  Add( array, [ string, key ] );
  H.node_indices[string] = Length( array );
  DecreaseKey( H, string, key );
end );

InstallMethod( @__MODULE__,  IsEmptyHeap,
               [ IsStringMinHeap ],
function( H )
  return IsEmpty( H.array );
end );

InstallMethod( @__MODULE__,  ExtractMin,
               [ IsStringMinHeap ],
function( H )
  local array, node, key;
  array = H.array;
  node = array[ 1 ];
  Swap( H, 1, Length( array ) );
  Remove( array );
  key = H.str( node );
  H.node_indices[key] = nothing;
  if !IsEmpty( array )
    Heapify( H, 1 );
  end;
  return node;
end );

InstallMethod( @__MODULE__,  DecreaseKey,
               [ IsStringMinHeap, IsString, IsInt ],
function( H, string, key )
  local array, i, parent;
  array = H.array;
  i = H.node_indices[string];
  array[ i ][ 2 ] = key;
  parent = int( i / 2 );
  while parent > 0 && H.key( array[ i ] ) < H.key( array[ parent ] )
    Swap( H, i, parent );
    i = parent;
    parent = int( i / 2 );
  end;
end );

InstallMethod( @__MODULE__,  Swap,
               [ IsStringMinHeap, IsPosInt, IsPosInt ],
function( H, i, j )
  local array, node_indices, str, tmp, key;
  array = H.array;
  node_indices = H.node_indices;
  str = H.str;
  tmp = array[ i ];
  array[ i ] = array[ j ];
  array[ j ] = tmp;
  key = str( array[ i ] );
  node_indices[key] = i;
  key = str( array[ j ] );
  node_indices[key] = j;
end );

InstallMethod( @__MODULE__,  Contains,
               [ IsStringMinHeap, IsString ],
function( H, string )
  return IsBound( H.node_indices[string] );
end );

InstallMethod( @__MODULE__,  Heapify,
               [ IsStringMinHeap, IsPosInt ],
function( H, i )
  local key, array, left, right, smallest;
  key = H.key;
  array = H.array;
  left = 2 * i;
  right = 2 * i + 1;
  smallest = i;
  if left <= HeapSize( H ) && key( array[ left ] ) < key( array[ smallest ] )
    smallest = left;
  end;
  if right <= HeapSize( H ) && key( array[ right ] ) < key( array[ smallest ] )
    smallest = right;
  end;
  if smallest != i
    Swap( H, i, smallest );
    Heapify( H, smallest );
  end;
end );


InstallMethod( @__MODULE__,  PrintTree,
               [ IsObject, IsFunction, IsFunction ],
function( root, print_node, get_children )
  PrintTreeRec( root, print_node, get_children, 0 );
end );

InstallMethod( @__MODULE__,  PrintTreeRec,
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
## Some print functions
##
#################################

##
@InstallGlobalFunction( InstalledMethodsOfCategory,
  
  function( cell )
    local weight_list, list_of_methods, i, current_weight, can_compute, cannot_compute;
    
    if IsCapCategory( cell )
        weight_list = cell.derivations_weight_list;
    elseif IsCapCategoryCell( cell )
        weight_list = CapCategory( cell ).derivations_weight_list;
    else
        Error( "Input must be a category || a cell" );
    end;
    
    list_of_methods = Operations( CAP_INTERNAL_DERIVATION_GRAPH );
    
    list_of_methods = AsSortedList( list_of_methods );
    
    can_compute = [ ];
    cannot_compute = [ ];
    
    for i in list_of_methods
        
        current_weight = CurrentOperationWeight( weight_list, i );
        
        if current_weight < Inf
            Add( can_compute, [ i, current_weight ] );
        else
            Add( cannot_compute, i );
        end;
        
    end;
    
    Print( "Can do the following basic methods at the moment:\n" );
    
    for i in can_compute
        Print( "+ ", i[ 1 ], ", weight ", string( i[ 2 ] ), "\n" );
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
    local category_weight_list, current_weight, current_derivation, currently_installed_funcs, to_delete, weight_list, category_getter_string, possible_derivations, category_filter, weight, found, i, x, final_derivation;
    
    if IsFunction( name )
        name = NameFunction( name );
    end;
    
    if !IsString( name )
        Error( "Usage is <category>,<string> || <category>,<CAP operation>\n" );
        return;
    end;
    
    if !IsBound( CAP_INTERNAL_METHOD_NAME_RECORD[name] )
        Error( name, " is !the name of a CAP operation." );
        return;
    end;
    
    category_weight_list = category.derivations_weight_list;
    
    current_weight = CurrentOperationWeight( category_weight_list, name );
    
    if current_weight < Inf
    
        current_derivation = DerivationOfOperation( category_weight_list, name );
        
        Print( Name( category ), " can already compute ", TextAttr.b4, name, TextAttr.reset, " with weight " , current_weight, ".\n" );
        
        if current_derivation == fail
            
            if IsBound( category.primitive_operations[name] ) && category.primitive_operations[name] == true
                
                Print( "It was given as a primitive operation.\n" );
                
            else
                
                Print( "It was installed as a final || precompiled derivation.\n" );
                
            end;
            
            currently_installed_funcs = category.added_functions[name];
            
            # delete overwritten funcs
            to_delete = [ ];
            
            for i in (1):(Length( currently_installed_funcs ))
                
                if ForAny( ((i+1)):(Length( currently_installed_funcs )), j -> currently_installed_funcs[i][2] == currently_installed_funcs[j][2] )
                    
                    Add( to_delete, i );
                    
                end;
                
            end;
            
            currently_installed_funcs = currently_installed_funcs[Difference( (1):(Length( currently_installed_funcs )), to_delete )];
            
        else
            
            Print( "It was derived by ", TextAttr.b3, DerivationName( current_derivation ), TextAttr.reset, " using \n" );
            
            for x in UsedOperationsWithMultiplesAndCategoryGetters( current_derivation )
                
                if x[3] == fail
                    
                    weight_list = category_weight_list;
                    category_getter_string = "";
                    
                else
                    
                    weight_list = x[3](category).derivations_weight_list;
                    category_getter_string = Concatenation( " ⥉ category obtained by applying ", string( x[3] ) );
                    
                end;
                
                Print( "* ", TextAttr.b2, x[1], TextAttr.reset, " (", x[2], "x)", category_getter_string );
                Print( " installed with weight ", string( CurrentOperationWeight( weight_list, x[1] ) ) );
                Print( "\n" );
                
            end;
            
            currently_installed_funcs = [ pair( DerivationFunction( current_derivation ), [ ] ) ];
            
        end;
        
        Print( "\nThe following function" );
        
        if Length( currently_installed_funcs ) > 1
            Print( "s were" );
        else
            Print( " was" );
        end;
        
        Print( " installed for this operation:\n\n" );
        
        for i in currently_installed_funcs
            
            Print( "Filters: " );
            Print( string( i[ 2 ] ) );
            Print( "\n\n" );
            Display( i[ 1 ] );
            Print( "\n" );
            Print( "Source: ", FilenameFunc( i[ 1 ] ), ":", StartlineFunc( i[ 1 ] ), "\n" );
            Print( "\n" );
            
        end;
        
        Print( "#######\n\n" );
        
    else
        
        Print( TextAttr.b4, name, TextAttr.reset, " is currently !installed for ", Name( category ), ".\n\n" );
        
    end;
    
    Print( "Possible derivations are:\n\n" );
    
    possible_derivations = List( DerivationsOfOperation( CAP_INTERNAL_DERIVATION_GRAPH, name ), d -> rec( derivation = d ) );
    
    for final_derivation in CAP_INTERNAL_FINAL_DERIVATION_LIST.final_derivation_list
        
        for current_derivation in final_derivation.derivations
            
            if TargetOperation( current_derivation ) == name
                
                Add( possible_derivations, rec(
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
        if IsProperty( category_filter ) && Tester( category_filter )( category ) && !category_filter( category )
            continue;
        elseif IsProperty( category_filter ) && !Tester( category_filter )( category )
            Print( "If ", Name( category ), " would be ", JoinStringsWithSeparator( Filtered( NamesFilter( category_filter ), name -> !StartsWith( name, "Has" ) ), " && " ), " then\n" );
            Print( TextAttr.b4, name, TextAttr.reset, " could be derived by\n" );
        elseif IsFunction( category_filter ) && !category_filter( category )
            Print( "If ", Name( category ), " would fulfill the conditions given by\n\n" );
            Display( category_filter );
            Print( "\nthen ", TextAttr.b4, name, TextAttr.reset, " could be derived by\n" );
        else
            Print( TextAttr.b4, name, TextAttr.reset, " can be derived by\n" );
        end;
        
        for x in UsedOperationsWithMultiplesAndCategoryGetters( current_derivation.derivation )
            
            if x[3] == fail
                
                weight_list = category_weight_list;
                category_getter_string = "";
                
            else
                
                weight_list = x[3](category).derivations_weight_list;
                category_getter_string = Concatenation( " ⥉ category obtained by applying ", string( x[3] ) );
                
            end;
            
            weight = CurrentOperationWeight( weight_list, x[1] );
            
            if weight < Inf
                Print( "* ", TextAttr.b2, x[1], TextAttr.reset, " (", x[2], "x)", category_getter_string, ", (already installed with weight ", weight,")" );
            else
                Print( "* ", TextAttr.b1, x[1], TextAttr.reset, " (", x[2], "x)", category_getter_string );
            end;
            
            Print( "\n" );
            
        end;
        
        Print( "with additional weight ", DerivationWeight( current_derivation.derivation ) );
        
        Assert( 0, IsBound( current_derivation.can_compute ) == IsBound( current_derivation.cannot_compute ) );
        
        if IsBound( current_derivation.can_compute )
            
            Print( "\n\nas a final derivation\nif the following additional operations could be computed\n" );
            
            found = false;
            
            for x in current_derivation.can_compute
                
                if x[3] == fail
                    
                    weight_list = category_weight_list;
                    category_getter_string = "";
                    
                else
                    
                    weight_list = x[3](category).derivations_weight_list;
                    category_getter_string = Concatenation( " ⥉ category obtained by applying ", string( x[3] ) );
                    
                end;
                
                weight = CurrentOperationWeight( weight_list, x[1] );
                
                if weight == Inf
                    
                    Print( "* ", x[1], "\n" );
                    found = true;
                    
                end;
                
            end;
            
            if !found
                
                Print( "(none)\n" );
                
            end;
            
            Print( "\nand the following additional operations could !be computed\n" );
            
            found = false;
            
            for x in current_derivation.cannot_compute
                
                weight = CurrentOperationWeight( weight_list, x );
                
                if weight < Inf
                    
                    Print( "* ", x, "\n" );
                    found = true;
                    
                end;
                
            end;
            
            if !found
                
                Print( "(none)\n" );
                
            end;
            
        else
            
            Print( ".\n" );
            
        end;
        
        Print( "\n" );
        
    end;
    
end );

@InstallGlobalFunction( ListPrimitivelyInstalledOperationsOfCategory,
  
  function( arg... )
    local cat, filter, names;
    
    if Length( arg ) < 1
        Error( "first argument needs to be <category>" );
    end;
    
    cat = arg[ 1 ];
    
    if Length( arg ) > 1
        filter = arg[ 2 ];
    else
        filter = fail;
    end;
    
    if IsCapCategoryCell( cat )
        cat = CapCategory( cat );
    end;
    
    if !IsCapCategory( cat )
        Error( "input must be category || cell" );
    end;
    
    names = Filtered( RecNames( cat.primitive_operations ), x -> cat.primitive_operations[x] );
    
    if filter != fail
        names = Filtered( names, i -> PositionSublist( i, filter ) != fail );
    end;
    
    return AsSortedList( names );
    
end );

@InstallGlobalFunction( ListInstalledOperationsOfCategory,
  
  function( arg... )
    local category, filter, weight_list, list_of_methods, list_of_installed_methods;
    
    if Length( arg ) < 1
        Error( "first argument needs to be <category>" );
    end;
    
    category = arg[ 1 ];
    
    if Length( arg ) > 1
        filter = arg[ 2 ];
    else
        filter = fail;
    end;
    
    if IsCapCategoryCell( category )
        category = CapCategory( category );
    end;
    
    if !IsCapCategory( category )
        Error( "input is !a category (cell)" );
        return;
    end;
    
    weight_list = category.derivations_weight_list;
    
    list_of_methods = Operations( CAP_INTERNAL_DERIVATION_GRAPH );
    
    list_of_methods = AsSortedList( list_of_methods );
    
    list_of_methods = Filtered( list_of_methods, i -> CurrentOperationWeight( weight_list, i ) < Inf );
    
    if filter != fail
        list_of_methods = Filtered( list_of_methods, i -> PositionSublist( i, filter ) != fail );
    end;
    
    return list_of_methods;
    
end );
