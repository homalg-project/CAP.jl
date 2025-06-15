# SPDX-License-Identifier: GPL-2.0-or-later
# CAP: Categories, Algorithms, Programming
#
# Implementations
#
@BindGlobal( "CAP_INTERNAL_VALID_RETURN_TYPES",
#! @BeginCode CAP_INTERNAL_VALID_RETURN_TYPES
    [
        "object",
        "morphism",
        "twocell",
        "object_in_range_category_of_homomorphism_structure",
        "morphism_in_range_category_of_homomorphism_structure",
        "bool",
        "list_of_objects",
        "list_of_morphisms",
        "list_of_lists_of_morphisms",
        "object_datum",
        "morphism_datum",
        "nonneg_integer_or_infinity",
        "list_of_elements_of_commutative_ring_of_linear_structure",
    ]
#! @EndCode
);

@BindGlobal( "CAP_INTERNAL_VALID_METHOD_NAME_RECORD_COMPONENTS",
#! @BeginCode CAP_INTERNAL_VALID_METHOD_NAME_RECORD_COMPONENTS
    [
        "filter_list",
        "input_arguments_names",
        "return_type",
        "output_source_getter_string",
        "output_source_getter_preconditions",
        "output_range_getter_string",
        "output_range_getter_preconditions",
        "with_given_object_position",
        "dual_operation",
        "dual_arguments_reversed",
        "dual_with_given_objects_reversed",
        "dual_preprocessor_func",
        "dual_preprocessor_func_string",
        "dual_postprocessor_func",
        "dual_postprocessor_func_string",
        "functorial",
        "compatible_with_congruence_of_morphisms",
        "redirect_function",
        "pre_function",
        "pre_function_full",
        "post_function",
    ]
#! @EndCode
);

# additional components which are deprecated or undocumented
@BindGlobal( "CAP_INTERNAL_LEGACY_METHOD_NAME_RECORD_COMPONENTS",
    [
        "is_merely_set_theoretic",
        "is_reflected_by_faithful_functor",
    ]
);

@BindGlobal( "CAP_INTERNAL_METHOD_NAME_RECORD", @rec( ) );

@InstallGlobalFunction( "CAP_INTERNAL_ENHANCE_NAME_RECORD_LIMITS",
  function ( limits )
    local object_specification, morphism_specification, source_position, type, range_position, unbound_morphism_positions, number_of_unbound_morphisms, unbound_objects, morphism, unbound_object_positions, number_of_unbound_objects, targets, target_positions, nontarget_positions, number_of_targets, number_of_nontargets, diagram_filter_list, diagram_arguments_names, limit, position;
    
    for limit in limits
        object_specification = limit.object_specification;
        morphism_specification = limit.morphism_specification;
        
        #### check that given diagram is well-defined
        if (!(IsDenseList( object_specification ) && IsDenseList( morphism_specification )))
            Error( "the given diagram is not well-defined" );
        end;

        if (Length( object_specification ) == 0 && Length( morphism_specification ) > 0)
            Error( "the given diagram is not well-defined" );
        end;
        
        if (!(ForAll( object_specification, object -> object in [ "fixedobject", "varobject" ] )))
            Error( "the given diagram is not well-defined" );
        end;

        for morphism in morphism_specification
            if (!(IsList( morphism ) && Length( morphism ) == 3))
                Error( "the given diagram is not well-defined" );
            end;
            source_position = morphism[1];
            type = morphism[2];
            range_position = morphism[3];

            if (!(IsInt( source_position ) && source_position >= 1 && source_position <= Length( object_specification )))
                Error( "the given diagram is not well-defined" );
            end;

            if (!(IsInt( range_position ) && range_position >= 1 && range_position <= Length( object_specification )))
                Error( "the given diagram is not well-defined" );
            end;

            if (@not type in [ "fixedmorphism", "varmorphism", "zeromorphism" ])
                Error( "the given diagram is not well-defined" );
            end;

            if (type == "fixedmorphism" && (object_specification[source_position] == "varobject" || object_specification[range_position] == "varobject"))
                Error( "the given diagram is not well-defined" );
            end;
        end;

        #### get number of variables
        # morphisms
        unbound_morphism_positions = PositionsProperty( morphism_specification, x -> x[2] == "varmorphism" || x[2] == "fixedmorphism" );
        if (Length( unbound_morphism_positions ) == 0)
            number_of_unbound_morphisms = 0;
        elseif (Length( unbound_morphism_positions ) == 1 && morphism_specification[unbound_morphism_positions[1]][2] == "fixedmorphism")
            number_of_unbound_morphisms = 1;
        else
            number_of_unbound_morphisms = 2;
        end;

        limit.unbound_morphism_positions = unbound_morphism_positions;
        limit.number_of_unbound_morphisms = number_of_unbound_morphisms;

        if (@not ForAll( unbound_morphism_positions, i -> morphism_specification[i][2] == "fixedmorphism" || i == Length( unbound_morphism_positions ) ))
            Error( "diagrams of the given type are not supported" );
        end;

        # objects
        unbound_objects = StructuralCopy( object_specification );
        for position in unbound_morphism_positions
            morphism = morphism_specification[position];
            source_position = morphism[1];
            range_position = morphism[3];

            unbound_objects[source_position] = "";
            unbound_objects[range_position] = "";
        end;
        unbound_object_positions = PositionsProperty( unbound_objects, x -> x != "" );
        if (Length( unbound_object_positions ) == 0)
            number_of_unbound_objects = 0;
        elseif (Length( unbound_object_positions ) == 1 && object_specification[unbound_object_positions[1]] == "fixedobject")
            number_of_unbound_objects = 1;
        else
            number_of_unbound_objects = 2;
        end;

        limit.unbound_object_positions = unbound_object_positions;
        limit.number_of_unbound_objects = number_of_unbound_objects;

        if (@not ForAll( unbound_object_positions, i -> object_specification[i] == "fixedobject" || i == Length( unbound_object_positions ) ))
            Error( "diagrams of the given type are not supported" );
        end;

        # (non-)targets
        targets = StructuralCopy( object_specification );
        for morphism in morphism_specification
            range_position = morphism[3];
            
            targets[range_position] = "";
        end;
        target_positions = PositionsProperty( targets, x -> x != "" );
        nontarget_positions = PositionsProperty( targets, x -> x == "" );
        if (Length( target_positions ) == 0)
            number_of_targets = 0;
        elseif (Length( target_positions ) == 1 && object_specification[target_positions[1]] == "fixedobject")
            number_of_targets = 1;
        else
            number_of_targets = 2;
        end;
        if (Length( nontarget_positions ) == 0)
            number_of_nontargets = 0;
        elseif (Length( nontarget_positions ) == 1 && object_specification[nontarget_positions[1]] == "fixedobject")
            number_of_nontargets = 1;
        else
            number_of_nontargets = 2;
        end;

        limit.target_positions = target_positions;
        limit.number_of_targets = number_of_targets;
        limit.nontarget_positions = nontarget_positions;
        limit.number_of_nontargets = number_of_nontargets;

        #### get filter list and names of input arguments of the diagram
        diagram_filter_list = [ ];
        diagram_arguments_names = [ ];
        if (number_of_unbound_objects == 1)
            Add( diagram_filter_list, "object" );
            Add( diagram_arguments_names, "X" );
        elseif (number_of_unbound_objects > 1)
            Add( diagram_filter_list, "list_of_objects" );
            Add( diagram_arguments_names, "objects" );
        end;
        if (number_of_unbound_morphisms == 1)
            Add( diagram_filter_list, "morphism" );
            Add( diagram_arguments_names, "alpha" );
        elseif (number_of_unbound_morphisms > 1)
            if (number_of_targets == 1)
                Add( diagram_filter_list, "object" );
                Add( diagram_arguments_names, "Y" );
            end;
            Add( diagram_filter_list, "list_of_morphisms" );
            Add( diagram_arguments_names, "morphisms" );
        end;

        limit.diagram_filter_list = diagram_filter_list;
        limit.diagram_arguments_names = diagram_arguments_names;
        
        #### set default projection/injection/universal morphism names
        if (number_of_targets > 0 && @not @IsBound( limit.limit_projection_name ))
            limit.limit_projection_name = @Concatenation( "ProjectionInFactorOf", limit.limit_object_name );
        end;
        if (@not @IsBound( limit.limit_universal_morphism_name ))
            limit.limit_universal_morphism_name = @Concatenation( "UniversalMorphismInto", limit.limit_object_name );
        end;

        if (number_of_targets > 0 && @not @IsBound( limit.colimit_injection_name ))
            limit.colimit_injection_name = @Concatenation( "InjectionOfCofactorOf", limit.colimit_object_name );
        end;
        if (@not @IsBound( limit.colimit_universal_morphism_name ))
            limit.colimit_universal_morphism_name = @Concatenation( "UniversalMorphismFrom", limit.colimit_object_name );
        end;
        
        if (number_of_targets > 0)
            limit.limit_projection_with_given_name = @Concatenation( limit.limit_projection_name, "WithGiven", limit.limit_object_name );
            limit.colimit_injection_with_given_name = @Concatenation( limit.colimit_injection_name, "WithGiven", limit.colimit_object_name );
        end;
        
        limit.limit_universal_morphism_with_given_name = @Concatenation( limit.limit_universal_morphism_name, "WithGiven", limit.limit_object_name );
        limit.colimit_universal_morphism_with_given_name = @Concatenation( limit.colimit_universal_morphism_name, "WithGiven", limit.colimit_object_name );
        
        limit.limit_functorial_name = @Concatenation( limit.limit_object_name, "Functorial" );
        limit.colimit_functorial_name = @Concatenation( limit.colimit_object_name, "Functorial" );

        limit.limit_functorial_with_given_name = @Concatenation( limit.limit_functorial_name, "WithGiven", limit.limit_object_name, "s" );
        limit.colimit_functorial_with_given_name = @Concatenation( limit.colimit_functorial_name, "WithGiven", limit.colimit_object_name, "s" );

        if (limit.number_of_nontargets == 1)
            limit.limit_morphism_to_sink_name = @Concatenation( "MorphismFrom", limit.limit_object_name, "ToSink" );
            limit.colimit_morphism_from_source_name = @Concatenation( "MorphismFromSourceTo", limit.colimit_object_name );
        end;

        if (Length( diagram_filter_list ) > 0)
            if (limit.number_of_targets == 1)
                limit.diagram_morphism_filter_list = [ "morphism" ];
                limit.diagram_morphism_arguments_names = [ "mu" ];
            else
                limit.diagram_morphism_filter_list = [ "list_of_morphisms" ];
                limit.diagram_morphism_arguments_names = [ "L" ];
            end;
        else
            limit.diagram_morphism_filter_list = [ ];
            limit.diagram_morphism_arguments_names = [ ];
        end;
        
        limit.functorial_source_diagram_arguments_names = limit.diagram_arguments_names;
        limit.functorial_range_diagram_arguments_names = List( limit.diagram_arguments_names, x -> @Concatenation( x, "p" ) );
        
    end;
end );

@BindGlobal( "CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES", @FunctionWithNamedArguments(
  [
    [ "subset_only", false ],
  ],
  function ( CAP_NAMED_ARGUMENTS, method_record, entry_name, generated_entry )
  local excluded_names, method_record_entry, name;
    
    excluded_names = [ "function_name", "pre_function", "pre_function_full", "post_function" ];
    
    if (@not @IsBound( method_record[entry_name] ))
        Display( @Concatenation( "WARNING: The method record is missing a component named \"", entry_name, "\" which is expected by the validator.\n" ) );
        return;
    end;
    
    method_record_entry = method_record[entry_name];
    
    for name in RecNames( method_record_entry )
        if (name in excluded_names)
            continue;
        end;
        if (@not @IsBound( generated_entry[name] ))
            if (subset_only)
                continue;
            else
                Display( @Concatenation( "WARNING: The entry \"", entry_name, "\" in the method record has a component named \"", name, "\" which is not expected by the validator.\n" ) );
            end;
        elseif (method_record_entry[name] != generated_entry[name])
            Display( @Concatenation( "WARNING: The entry \"", entry_name, "\" in the method record has a component named \"", name, "\" with value \"", StringGAP( method_record_entry[name] ), "\". The value expected by the validator is \"", StringGAP( generated_entry[name] ), "\".\n" ) );
        end;
    end;
    for name in RecNames( generated_entry )
        if (name in excluded_names)
            continue;
        end;
        if (@not @IsBound( method_record_entry[name] ))
            Display( @Concatenation( "WARNING: The entry \"", entry_name, "\" in the method record is missing a component named \"", name, "\" which is expected by the validator.\n" ) );
        end;
    end;
end ) );

@InstallGlobalFunction( CAP_INTERNAL_VALIDATE_LIMITS_IN_NAME_RECORD,
  function ( method_name_record, limits )
    local make_record_with_given, make_colimit, object_filter_list, object_input_arguments_names, projection_filter_list, projection_input_arguments_names, projection_range_getter_string, morphism_to_sink_filter_list, morphism_to_sink_input_arguments_names, morphism_to_sink_range_getter_string, universal_morphism_filter_list, universal_morphism_input_arguments_names, object_record, projection_record, morphism_to_sink_record, universal_morphism_record, functorial_record, functorial_with_given_record, limit;
    
    #### helper functions
    make_record_with_given = function ( record, object_name, coobject_name )
        record = StructuralCopy( record );
        
        record.function_name = @Concatenation( record.function_name, "WithGiven", object_name );
        Add( record.filter_list, "object" );
        Add( record.input_arguments_names, "P" );
        if (record.with_given_object_position == "Source")
            record.output_source_getter_string = "P";
            record.output_source_getter_preconditions = [ ];
        else
            record.output_range_getter_string = "P";
            record.output_range_getter_preconditions = [ ];
        end;
        record.dual_operation = @Concatenation( record.dual_operation, "WithGiven", coobject_name );
        @Unbind( record.with_given_object_position );

        return record;
    end;

    make_colimit = function ( limit, record )
      local orig_function_name, orig_output_source_getter_string, orig_output_source_getter_preconditions;
        
        record = StructuralCopy( record );
        
        orig_function_name = record.function_name;
        record.function_name = record.dual_operation;
        record.dual_operation = orig_function_name;
        
        if (@IsBound( record.functorial ))
            
            @Assert( 0, record.functorial == limit.limit_functorial_name );
            
            record.functorial = limit.colimit_functorial_name;
            
        end;
        
        if (@IsBound( record.with_given_object_position ))
            if (record.with_given_object_position == "Source")
                record.with_given_object_position = "Range";
            elseif (record.with_given_object_position == "Range")
                record.with_given_object_position = "Source";
            end;
        end;
        
        # reverse output getters, except if the input is reversed
        if (!(@IsBound( record.dual_arguments_reversed ) && record.dual_arguments_reversed))
            
            orig_output_source_getter_string = fail;
            
            if (@IsBound( record.output_source_getter_string ))
                
                orig_output_source_getter_string = record.output_source_getter_string;
                orig_output_source_getter_preconditions = record.output_source_getter_preconditions;
                
            end;
            
            if (@IsBound( record.output_range_getter_string ))
                
                record.output_source_getter_string = record.output_range_getter_string;
                record.output_source_getter_preconditions = record.output_range_getter_preconditions;
                
            else
                
                @Unbind( record.output_source_getter_string );
                @Unbind( record.output_source_getter_preconditions );
                
            end;
            
            if (orig_output_source_getter_string != fail)
                
                record.output_range_getter_string = orig_output_source_getter_string;
                record.output_range_getter_preconditions = orig_output_source_getter_preconditions;
                
            else
                
                @Unbind( record.output_range_getter_string );
                @Unbind( record.output_range_getter_preconditions );
                
            end;
            
        end;
        
        if (@IsBound( record.output_source_getter_string ))
            
            record.output_source_getter_string = ReplacedString( record.output_source_getter_string, "Source", "tmp" );
            record.output_source_getter_string = ReplacedString( record.output_source_getter_string, "Range", "Source" );
            record.output_source_getter_string = ReplacedString( record.output_source_getter_string, "tmp", "Range" );
            
            if (IsEmpty( record.output_source_getter_preconditions ))
                # do nothing
            elseif (record.output_source_getter_preconditions == [ [ limit.limit_object_name, 1 ] ])
                record.output_source_getter_string = ReplacedString( record.output_source_getter_string, limit.limit_object_name, limit.colimit_object_name );
                record.output_source_getter_preconditions = [ [ limit.colimit_object_name, 1 ] ];
            else
                Error( "this case is not supported yet" );
            end;
            
        end;
        
        if (@IsBound( record.output_range_getter_string ))
            
            record.output_range_getter_string = ReplacedString( record.output_range_getter_string, "Source", "tmp" );
            record.output_range_getter_string = ReplacedString( record.output_range_getter_string, "Range", "Source" );
            record.output_range_getter_string = ReplacedString( record.output_range_getter_string, "tmp", "Range" );
            
            if (IsEmpty( record.output_range_getter_preconditions ))
                # do nothing
            elseif (record.output_range_getter_preconditions == [ [ limit.limit_object_name, 1 ] ])
                record.output_range_getter_string = ReplacedString( record.output_range_getter_string, limit.limit_object_name, limit.colimit_object_name );
                record.output_range_getter_preconditions = [ [ limit.colimit_object_name, 1 ] ];
            else
                Error( "this case is not supported yet" );
            end;
            
        end;
        
        return record;
    end;

    for limit in limits
        
        #### get filter lists and io types
        object_filter_list = @Concatenation( [ "category" ], StructuralCopy( limit.diagram_filter_list ) );
        object_input_arguments_names = @Concatenation( [ "cat" ], limit.diagram_arguments_names );
        
        # only used if limit.number_of_targets > 0
        projection_filter_list = @Concatenation( [ "category" ], StructuralCopy( limit.diagram_filter_list ) );
        projection_input_arguments_names = @Concatenation( [ "cat" ], limit.diagram_arguments_names );
        if (limit.number_of_targets > 1)
            Add( projection_filter_list, "integer" );
            Add( projection_input_arguments_names, "k" );
        end;
        if (limit.target_positions == limit.unbound_object_positions)
            # range can be derived from the objects
            if (limit.number_of_targets == 1)
                projection_range_getter_string = "X";
            else
                projection_range_getter_string = "objects[k]";
            end;
        elseif (limit.target_positions == List( limit.unbound_morphism_positions, i -> limit.morphism_specification[i][1] ))
            # range can be derived from the morphisms as sources
            if (limit.number_of_unbound_morphisms == 1)
                projection_range_getter_string = "Source( alpha )";
            elseif (limit.number_of_targets == 1)
                projection_range_getter_string = "Y";
            else
                projection_range_getter_string = "Source( morphisms[k] )";
            end;
        elseif (limit.target_positions == List( limit.unbound_morphism_positions, i -> limit.morphism_specification[i][3] ))
            # range can be derived from the morphisms as ranges
            if (limit.number_of_unbound_morphisms == 1)
                projection_range_getter_string = "Range( alpha )";
            elseif (limit.number_of_targets == 1)
                projection_range_getter_string = "Y";
            else
                projection_range_getter_string = "Range( morphisms[k] )";
            end;
        else
            Error( "Warning: cannot express range getter" );
        end;

        # only used if limit.number_of_nontargets == 1
        morphism_to_sink_filter_list = @Concatenation( [ "category" ], StructuralCopy( limit.diagram_filter_list ) );
        morphism_to_sink_input_arguments_names = @Concatenation( [ "cat" ], limit.diagram_arguments_names );
        morphism_to_sink_range_getter_string = [ StructuralCopy( limit.diagram_arguments_names ), [ ] ];
        if (limit.number_of_unbound_morphisms == 1)
            morphism_to_sink_range_getter_string = "Range( alpha )";
        elseif (limit.number_of_unbound_morphisms > 1)
            morphism_to_sink_range_getter_string = "Range( morphisms[1] )";
        end;

        universal_morphism_filter_list = @Concatenation( [ "category" ], StructuralCopy( limit.diagram_filter_list ), [ "object" ] );
        universal_morphism_input_arguments_names = @Concatenation( [ "cat" ], limit.diagram_arguments_names, [ "T" ] );
        if (limit.number_of_targets == 1)
            Add( universal_morphism_filter_list, "morphism" );
            Add( universal_morphism_input_arguments_names, "tau" );
        elseif (limit.number_of_targets > 1)
            Add( universal_morphism_filter_list, "list_of_morphisms" );
            Add( universal_morphism_input_arguments_names, "tau" );
        end;

        
        #### get base records
        object_record =  @rec(
            function_name = limit.limit_object_name,
            filter_list = object_filter_list,
            input_arguments_names = object_input_arguments_names,
            return_type = "object",
            dual_operation = limit.colimit_object_name,
            functorial = limit.limit_functorial_name,
        );

        if (limit.number_of_targets > 0)
            projection_record = @rec(
                function_name = limit.limit_projection_name,
                filter_list = projection_filter_list,
                input_arguments_names = projection_input_arguments_names,
                return_type = "morphism",
                output_range_getter_string = projection_range_getter_string,
                output_range_getter_preconditions = [ ],
                with_given_object_position = "Source",
                dual_operation = limit.colimit_injection_name,
            );
        end;

        if (limit.number_of_nontargets == 1)
            morphism_to_sink_record = @rec(
                function_name = @Concatenation( "MorphismFrom", limit.limit_object_name, "ToSink" ),
                filter_list = morphism_to_sink_filter_list,
                input_arguments_names = morphism_to_sink_input_arguments_names,
                return_type = "morphism",
                output_range_getter_string = morphism_to_sink_range_getter_string,
                output_range_getter_preconditions = [ ],
                with_given_object_position = "Source",
                dual_operation = limit.colimit_morphism_from_source_name,
            );
        end;

        universal_morphism_record = @rec(
            function_name = limit.limit_universal_morphism_name,
            filter_list = universal_morphism_filter_list,
            input_arguments_names = universal_morphism_input_arguments_names,
            return_type = "morphism",
            output_source_getter_string = "T",
            output_source_getter_preconditions = [ ],
            with_given_object_position = "Range",
            dual_operation = limit.colimit_universal_morphism_name,
        );
        
        functorial_record = @rec(
            function_name = limit.limit_functorial_name,
            filter_list = @Concatenation( [ "category" ], limit.diagram_filter_list, limit.diagram_morphism_filter_list, limit.diagram_filter_list ),
            input_arguments_names = @Concatenation( [ "cat" ], limit.functorial_source_diagram_arguments_names, limit.diagram_morphism_arguments_names, limit.functorial_range_diagram_arguments_names ),
            return_type = "morphism",
            # object_name
            output_source_getter_string = ReplacedStringViaRecord(
                "object_name( arguments... )",
                @rec( object_name = limit.limit_object_name, arguments = @Concatenation( [ "cat" ], limit.functorial_source_diagram_arguments_names ) )
            ),
            output_source_getter_preconditions = [ [ limit.limit_object_name, 1 ] ],
            output_range_getter_string = ReplacedStringViaRecord(
                "object_name( arguments... )",
                @rec( object_name = limit.limit_object_name, arguments = @Concatenation( [ "cat" ], limit.functorial_range_diagram_arguments_names ) )
            ),
            output_range_getter_preconditions = [ [ limit.limit_object_name, 1 ] ],
            with_given_object_position = "both",
            dual_operation = limit.colimit_functorial_name,
            dual_arguments_reversed = true,
        );
        
        functorial_with_given_record = @rec(
            function_name = limit.limit_functorial_with_given_name,
            filter_list = @Concatenation( [ "category", "object" ], limit.diagram_filter_list, limit.diagram_morphism_filter_list, limit.diagram_filter_list, [ "object" ] ),
            input_arguments_names = @Concatenation( [ "cat", "P" ], limit.functorial_source_diagram_arguments_names, limit.diagram_morphism_arguments_names, limit.functorial_range_diagram_arguments_names, [ "Pp" ] ),
            return_type = "morphism",
            output_source_getter_string = "P",
            output_source_getter_preconditions = [ ],
            output_range_getter_string = "Pp",
            output_range_getter_preconditions = [ ],
            dual_operation = limit.colimit_functorial_with_given_name,
            dual_arguments_reversed = true,
        );
        
        if (limit.number_of_unbound_morphisms == 0)
            
            # The diagram has only objects as input -> all operations are compatible with the congruence of morphisms:
            # For the universal morphisms and functorials, this follows from the universal property.
            # All other operations are automatically compatible because they do not have morphisms as input.
            
            # if limit.number_of_targets == 0, the universal morphism has no test morphism as input anyway
            if (limit.number_of_targets > 0)
                
                universal_morphism_record.compatible_with_congruence_of_morphisms = true;
                functorial_record.compatible_with_congruence_of_morphisms = true;
                functorial_with_given_record.compatible_with_congruence_of_morphisms = true;
                
            end;
            
        else
            
            # The universal object might depend on the morphism datum.
            # Thus, the operations are in general not compatible with the congruence of morphisms.
            
            object_record.compatible_with_congruence_of_morphisms = false;
            projection_record.compatible_with_congruence_of_morphisms = false;
            morphism_to_sink_record.compatible_with_congruence_of_morphisms = false;
            universal_morphism_record.compatible_with_congruence_of_morphisms = false;
            functorial_record.compatible_with_congruence_of_morphisms = false;
            functorial_with_given_record.compatible_with_congruence_of_morphisms = false;
            
        end;
        
        #### validate limit records
        CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( method_name_record, limit.limit_object_name, object_record );
        
        if (limit.number_of_targets > 0)
            CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( method_name_record, limit.limit_projection_name, projection_record );
            CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( method_name_record, limit.limit_projection_with_given_name, make_record_with_given( projection_record, limit.limit_object_name, limit.colimit_object_name ) );
        end;
        
        if (limit.number_of_nontargets == 1)
            CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( method_name_record, limit.limit_morphism_to_sink_name, morphism_to_sink_record );
            CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( method_name_record, @Concatenation( limit.limit_morphism_to_sink_name, "WithGiven", limit.limit_object_name ), make_record_with_given( morphism_to_sink_record, limit.limit_object_name, limit.colimit_object_name ) );
        end;
        
        CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( method_name_record, limit.limit_universal_morphism_name, universal_morphism_record );
        CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( method_name_record, limit.limit_universal_morphism_with_given_name, make_record_with_given( universal_morphism_record, limit.limit_object_name, limit.colimit_object_name ) );
        
        # GAP has a limit of 6 arguments per operation -> operations which would have more than 6 arguments have to work around this
        if (Length( functorial_with_given_record.filter_list ) <= 6)
            
            CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( method_name_record, functorial_record.function_name, functorial_record );
            CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( method_name_record, functorial_with_given_record.function_name, functorial_with_given_record );
            
        end;
        
        #### validate colimit records
        CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( method_name_record, limit.colimit_object_name, make_colimit( limit, object_record ) );
        
        if (limit.number_of_targets > 0)
            CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( method_name_record, limit.colimit_injection_name, make_colimit( limit, projection_record ) );
            CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( method_name_record, limit.colimit_injection_with_given_name, make_record_with_given( make_colimit( limit, projection_record ), limit.colimit_object_name, limit.limit_object_name ) );
        end;
        
        if (limit.number_of_nontargets == 1)
            CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( method_name_record, limit.colimit_morphism_from_source_name, make_colimit( limit, morphism_to_sink_record ) );
            CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( method_name_record, @Concatenation( limit.colimit_morphism_from_source_name, "WithGiven", limit.colimit_object_name ), make_record_with_given( make_colimit( limit, morphism_to_sink_record ), limit.colimit_object_name, limit.limit_object_name ) );
        end;
        
        CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( method_name_record, limit.colimit_universal_morphism_name, make_colimit( limit, universal_morphism_record ) );
        CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( method_name_record, limit.colimit_universal_morphism_with_given_name, make_record_with_given( make_colimit( limit, universal_morphism_record ), limit.colimit_object_name, limit.limit_object_name ) );
        
        # GAP has a limit of 6 arguments per operation -> operations which would have more than 6 arguments have to work around this
        if (Length( functorial_with_given_record.filter_list ) <= 6)
            
            CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( method_name_record, functorial_record.dual_operation, make_colimit( limit, functorial_record ) );
            CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( method_name_record, functorial_with_given_record.dual_operation, make_colimit( limit, functorial_with_given_record ) );
            
        end;
        
    end;
    
end );

@BindGlobal( "CAP_INTERNAL_METHOD_RECORD_REPLACEMENTS", @rec( ) );

@InstallGlobalFunction( CAP_INTERNAL_ADD_REPLACEMENTS_FOR_METHOD_RECORD,
  function( replacement_data )
    local current_name;

    for current_name in RecNames( replacement_data )
        if (@IsBound( CAP_INTERNAL_METHOD_RECORD_REPLACEMENTS[current_name] ))
            Error( @Concatenation( current_name, " already has a replacement" ) );
        end;
        CAP_INTERNAL_METHOD_RECORD_REPLACEMENTS[current_name] = replacement_data[current_name];
    end;
    
end );

@BindGlobal( "CAP_INTERNAL_OPPOSITE_PROPERTY_PAIRS_FOR_OBJECTS", [ ] );

@BindGlobal( "CAP_INTERNAL_OPPOSITE_PROPERTY_PAIRS_FOR_MORPHISMS", [ ] );

@InstallGlobalFunction( CAP_INTERNAL_FIND_OPPOSITE_PROPERTY_PAIRS_IN_METHOD_NAME_RECORD,
  function( method_name_record )
    local recnames, current_recname, current_entry, current_rec, category_property_list, elem;
    
    recnames = RecNames( method_name_record );
    
    for current_recname in recnames
        
        current_rec = method_name_record[current_recname];
        
        if (!(current_rec.return_type == "bool" && Length( current_rec.filter_list ) == 2))
            continue;
        end;
        
        if (current_recname in [ "IsWellDefinedForObjects", "IsWellDefinedForMorphisms", "IsWellDefinedForTwoCells" ])
            continue;
        end;
        
        if (!(@IsBound( current_rec.dual_operation )) || current_rec.dual_operation == current_recname)
            
            current_entry = NameFunction( current_rec.operation );
            
        else
            
            current_entry = [ NameFunction( current_rec.operation ), NameFunction( method_name_record[current_rec.dual_operation].operation ) ];
            current_entry = [ @Concatenation( current_entry[ 1 ], " vs ", current_entry[ 2 ] ), current_entry ];
            
        end;
        
        if (current_rec.filter_list[2] == "object")
            
            if (@not current_entry in CAP_INTERNAL_OPPOSITE_PROPERTY_PAIRS_FOR_OBJECTS)
                
                Add( CAP_INTERNAL_OPPOSITE_PROPERTY_PAIRS_FOR_OBJECTS, current_entry );
                
            end;
            
        elseif (current_rec.filter_list[2] == "morphism")
            
            if (@not current_entry in CAP_INTERNAL_OPPOSITE_PROPERTY_PAIRS_FOR_MORPHISMS)
                
                Add( CAP_INTERNAL_OPPOSITE_PROPERTY_PAIRS_FOR_MORPHISMS, current_entry );
                
            end;
            
        end;
        
    end;
    
end );

@BindGlobal( "CAP_INTERNAL_PREPARE_INHERITED_PRE_FUNCTION",
  function( func, drop_both )
    
    if (drop_both)
        
        return function( arg_list... )
            # drop second and last argument
            return CallFuncList( func, arg_list[@Concatenation( [ 1 ], (3):(Length( arg_list ) - 1) )] );
        end;
        
    else
        
        return function( arg_list... )
            # drop last argument
            return CallFuncList( func, arg_list[(1):(Length( arg_list ) - 1)] );
        end;
        
    end;
    
end );

@BindGlobal( "CAP_INTERNAL_CREATE_REDIRECTION",
  
  function( without_given_name, with_given_name, object_function_name, object_filter_list, object_arguments_positions )
    local object_function, with_given_name_function, is_attribute, attribute_tester;
    
    object_function = ValueGlobal( object_function_name );
    
    with_given_name_function = ValueGlobal( with_given_name );
    
    # Check if `object_function` is declared as an attribute and can actually be used as one in our context.
    is_attribute = IsAttribute( object_function ) && Length( object_filter_list ) <= 2 && IsSpecializationOfFilter( IsAttributeStoringRep, CAP_INTERNAL_REPLACED_STRING_WITH_FILTER( Last( object_filter_list ) ) );
    
    if (@not is_attribute)
        
        return function( arg... )
          local category, without_given_weight, with_given_weight, object_args, cache, cache_value;
            
            category = arg[ 1 ];
            
            without_given_weight = OperationWeight( category, without_given_name );
            with_given_weight = OperationWeight( category, with_given_name );
            
            # If the WithGiven version is more expensive than the WithoutGiven version, redirection makes no sense and
            # might even lead to inifite loops if the WithGiven version is derived from the WithoutGiven version.
            if (with_given_weight > without_given_weight)
                
                return [ false ];
                
            end;
            
            object_args = arg[ object_arguments_positions ];
            
            cache = GET_METHOD_CACHE( category, object_function_name, Length( object_arguments_positions ) );
            
            cache_value = CallFuncList( CacheValue, [ cache, object_args ] );
            
            if (cache_value == [ ])
                
                return [ false ];
                
            end;
            
            return [ true, CallFuncList( with_given_name_function, @Concatenation( arg, [ cache_value[ 1 ] ] ) ) ];
            
        end;
        
    else
        
        if (@not Length( object_arguments_positions ) in [ 1, 2 ])
            
            Error( "we can only handle attributes of the category or of a single object/morphism/twocell" );
            
        end;
        
        attribute_tester = Tester( object_function );
        
        return function( arg... )
          local category, without_given_weight, with_given_weight, object_args, cache_value, cache;
            
            category = arg[ 1 ];
            
            without_given_weight = OperationWeight( category, without_given_name );
            with_given_weight = OperationWeight( category, with_given_name );
            
            # If the WithGiven version is more expensive than the WithoutGiven version, redirection makes no sense and
            # might even lead to inifite loops if the WithGiven version is derived from the WithoutGiven version.
            if (with_given_weight > without_given_weight)
                
                return [ false ];
                
            end;
            
            object_args = arg[ object_arguments_positions ];

            if (attribute_tester( object_args[ Length( object_args ) ] ))
                
                cache_value = [ object_function( object_args[ Length( object_args ) ] ) ];
                
            else
                
                cache = GET_METHOD_CACHE( category, object_function_name, Length( object_arguments_positions ) );
                
                cache_value = CallFuncList( CacheValue, [ cache, object_args ] );
                
                if (cache_value == [ ])
                    
                    return [ false ];
                    
                end;
                
            end;
            
            return [ true, CallFuncList( with_given_name_function, @Concatenation( arg, [ cache_value[ 1 ] ] ) ) ];
            
        end;
        
    end;
    
end );

@BindGlobal( "CAP_INTERNAL_CREATE_POST_FUNCTION",
  
  function( source_range_object, object_function_name, object_filter_list, object_arguments_positions )
    local object_getter, object_function, cache_key_length, is_attribute, setter_function;
    
    if (source_range_object == "Source")
        object_getter = Source;
    elseif (source_range_object == "Range")
        object_getter = Range;
    else
        Error( "the first argument of CAP_INTERNAL_CREATE_POST_FUNCTION must be 'Source' or 'Range'" );
    end;
    
    object_function = ValueGlobal( object_function_name );
    
    cache_key_length = Length( object_arguments_positions );
    
    # Check if `object_function` is declared as an attribute and can actually be used as one in our context.
    is_attribute = IsAttribute( object_function ) && Length( object_filter_list ) <= 2 && IsSpecializationOfFilter( IsAttributeStoringRep, CAP_INTERNAL_REPLACED_STRING_WITH_FILTER( Last( object_filter_list ) ) );
    
    if (@not is_attribute)
    
        return function( arg... )
          local category, object_args, result, object;
            
            category = arg[ 1 ];
            
            object_args = arg[ object_arguments_positions ];
            
            result = arg[ Length( arg ) ];
            object = object_getter( result );
            
            SET_VALUE_OF_CATEGORY_CACHE( category, object_function_name, cache_key_length, object_args, object );
            
        end;
        
    else
        
        if (@not Length( object_arguments_positions ) in [ 1, 2 ])
            
            Error( "we can only handle attributes of the category or of a single object/morphism/twocell" );
            
        end;
        
        setter_function = Setter( object_function );
        
        return function( arg... )
          local category, object_args, result, object;
            
            category = arg[ 1 ];

            object_args = arg[ object_arguments_positions ];
            
            result = arg[ Length( arg ) ];
            object = object_getter( result );
            
            SET_VALUE_OF_CATEGORY_CACHE( category, object_function_name, cache_key_length, object_args, object );
            setter_function( object_args[ Length( object_args ) ], object );
            
        end;
        
    end;
    
end );

@InstallGlobalFunction( CAP_INTERNAL_ENHANCE_NAME_RECORD,
  function( record )
    local recnames, current_recname, current_rec, diff, number_of_arguments, func,
          without_given_name, with_given_prefix, with_given_names, with_given_name, without_given_rec, with_given_object_position, object_name,
          object_filter_list, with_given_object_filter, given_source_argument_name, given_range_argument_name, with_given_rec,
          collected_list, preconditions, can_always_compute_output_source_getter, can_always_compute_output_range_getter;
    
    recnames = RecNames( record );
    
    # loop before detecting With(out)Given pairs
    for current_recname in recnames
        
        current_rec = record[current_recname];
        
        diff = Difference( RecNames( current_rec ), CAP_INTERNAL_VALID_METHOD_NAME_RECORD_COMPONENTS );
        diff = Difference( diff, CAP_INTERNAL_LEGACY_METHOD_NAME_RECORD_COMPONENTS );
        
        if (@not IsEmpty( diff ))
            
            Print( "WARNING: The following method name record components are not known: " );
            Display( diff );
            
        end;
        
        # validity checks
        if (@not @IsBound( current_rec.return_type ))
            Error( "<current_rec> has no return_type" );
        end;
        
        if (current_rec.return_type in [ "other_object", "other_morphism" ])
            Error( "The return types \"other_object\" and \"other_morphism\" are not supported anymore. If you need those, please report this using the CAP_projects's issue tracker." );
        end;
        
        if (@not current_rec.return_type in CAP_INTERNAL_VALID_RETURN_TYPES)
            Error( "The return_type of <current_rec> does not appear in CAP_INTERNAL_VALID_RETURN_TYPES. Note that proper filters are not supported anymore." );
        end;
        
        if (current_rec.filter_list[1] != "category")
            
            Error( "The first entry of `filter_list` must be the string \"category\"." );
            
        end;
        
        if (ForAny( current_rec.filter_list, x -> x in [ "other_category", "other_object", "other_morphism", "other_twocell" ] ))
            Error( "The filters \"other_category\", \"other_object\", \"other_morphism\", and \"other_twocell\" are not supported anymore. If you need those, please report this using the CAP_projects's issue tracker." );
        end;
        
        if (@IsBound( current_rec.output_source_getter_preconditions ) && @not @IsBound( current_rec.output_source_getter_string ))
            
            Error( "output_source_getter_preconditions may only be set if output_source_getter_string is set" );
            
        end;
        
        if (@IsBound( current_rec.output_range_getter_preconditions ) && @not @IsBound( current_rec.output_range_getter_string ))
            
            Error( "output_range_getter_preconditions may only be set if output_range_getter_string is set" );
            
        end;
        
        current_rec.function_name = current_recname;
        
        if (@IsBound( current_rec.pre_function ) && IsString( current_rec.pre_function ))
            
            if (@IsBound( record[current_rec.pre_function] ) && @IsBound( record[current_rec.pre_function].pre_function ) && IsFunction( record[current_rec.pre_function].pre_function ))
                
                current_rec.pre_function = record[current_rec.pre_function].pre_function;
                
            else
                
                Error( "Could not find pre function for ", current_recname, ". ", current_rec.pre_function, " is not the name of an operation in the record, has no pre function, or has itself a string as pre function." );
                
            end;
            
        end;
        
        if (@IsBound( current_rec.pre_function_full ) && IsString( current_rec.pre_function_full ))
            
            if (@IsBound( record[current_rec.pre_function_full] ) && @IsBound( record[current_rec.pre_function_full].pre_function_full ) && IsFunction( record[current_rec.pre_function_full].pre_function_full ))
                
                current_rec.pre_function_full = record[current_rec.pre_function_full].pre_function_full;
                
            else
                
                Error( "Could not find full pre function for ", current_recname, ". ", current_rec.pre_function_full, " is not the name of an operation in the record, has no full pre function, or has itself a string as full pre function." );
                
            end;
            
        end;
        
        if (@IsBound( current_rec.redirect_function ) && IsString( current_rec.redirect_function ))
            
            if (@IsBound( record[current_rec.redirect_function] ) && @IsBound( record[current_rec.redirect_function].redirect_function ) && IsFunction( record[current_rec.redirect_function].redirect_function ))
                
                current_rec.redirect_function = record[current_rec.redirect_function].redirect_function;
                
            else
                
                Error( "Could not find redirect function for ", current_recname, ". ", current_rec.redirect_function, " is not the name of an operation in the record, has no redirect function, or has itself a string as redirect function." );
                
            end;
            
        end;
        
        number_of_arguments = Length( current_rec.filter_list );
        
        if (@IsBound( current_rec.pre_function ) && NumberArgumentsFunction( current_rec.pre_function ) >= 0 && NumberArgumentsFunction( current_rec.pre_function ) != number_of_arguments)
            Error( "the pre function of <current_rec> has the wrong number of arguments" );
        end;
        
        if (@IsBound( current_rec.pre_function_full ) && NumberArgumentsFunction( current_rec.pre_function_full ) >= 0 && NumberArgumentsFunction( current_rec.pre_function_full ) != number_of_arguments)
            Error( "the full pre function of <current_rec> has the wrong number of arguments" );
        end;
        
        if (@IsBound( current_rec.redirect_function ) && NumberArgumentsFunction( current_rec.redirect_function ) >= 0 && NumberArgumentsFunction( current_rec.redirect_function ) != number_of_arguments)
            Error( "the redirect function of <current_rec> has the wrong number of arguments" );
        end;
        
        if (@IsBound( current_rec.post_function ) && NumberArgumentsFunction( current_rec.post_function ) >= 0 && NumberArgumentsFunction( current_rec.post_function ) != number_of_arguments + 1)
            Error( "the post function of <current_rec> has the wrong number of arguments" );
        end;
        
        if (@IsBound( current_rec.dual_preprocessor_func ) && NumberArgumentsFunction( current_rec.dual_preprocessor_func ) >= 0 && NumberArgumentsFunction( current_rec.dual_preprocessor_func ) != number_of_arguments)
            Error( "the dual preprocessor function of ", current_recname, " has the wrong number of arguments" );
        end;
        
        if (@not ForAll( current_rec.filter_list, IsString ))
            Error( "Not all entries of filter_list of ", current_recname, " are strings. This is not supported anymore." );
        end;
        
        if (@not @IsBound( current_rec.install_convenience_without_category ))
            
            if (ForAny( [ "object", "morphism", "twocell", "list_of_objects", "list_of_morphisms", "list_of_twocells" ], filter -> filter in current_rec.filter_list ))
                
                current_rec.install_convenience_without_category = true;
                
            else
                
                current_rec.install_convenience_without_category = false;
                
            end;
            
        end;
        
        if (@IsBound( current_rec.universal_object_position ))
            
            Display( "WARNING: universal_object_position was renamed to with_given_object_position" );
            
            current_rec.with_given_object_position = current_rec.universal_object_position;
            
        end;
        
        if (@IsBound( current_rec.with_given_object_position ) && @not current_rec.with_given_object_position in [ "Source", "Range", "both" ])
            
            Error( "with_given_object_position must be one of the strings \"Source\", \"Range\", or \"both\", not ", current_rec.with_given_object_position );
            
        end;
        
        if (@not @IsBound( current_rec.is_with_given ))
            
            current_rec.is_with_given = false;
            
        end;
        
        if (@not @IsBound( current_rec.with_given_without_given_name_pair ))
            
            current_rec.with_given_without_given_name_pair = fail;
            
        end;
        
        if (@IsBound( current_rec.dual_operation ))
            
            # check that dual of the dual is the original operation
            
            if (@not @IsBound( record[current_rec.dual_operation] ))
                
                Error( "the dual operation must be added in the same call to `CAP_INTERNAL_ENHANCE_NAME_RECORD`" );
                
            end;
            
            if (@not @IsBound( record[current_rec.dual_operation].dual_operation ))
                
                Error( "the dual operation of ", current_recname, ", i.e. ", current_rec.dual_operation, ", has no dual operation"  );
                
            end;
            
            if (record[current_rec.dual_operation].dual_operation != current_recname)
                
                Error( "the dual operation of ", current_recname, ", i.e. ", current_rec.dual_operation, ", has the unexpected dual operation ", record[current_rec.dual_operation].dual_operation  );
                
            end;
            
        end;
        
        if (@not @IsBound( current_rec.dual_arguments_reversed ))
            
            current_rec.dual_arguments_reversed = false;
            
        end;
        
        if (Length( Filtered( [ "dual_preprocessor_func", "dual_arguments_reversed", "dual_with_given_objects_reversed" ],
                             name -> @IsBound( current_rec[name] ) && ( IsFunction( current_rec[name] ) || current_rec[name] == true )
                           ) ) >= 2)
            
            Error( "dual_preprocessor_func, dual_arguments_reversed == true and dual_with_given_objects_reversed == true are mutually exclusive" );
            
        end;
        
        if (@IsBound( current_rec.dual_preprocessor_func ))
            
            if (@IsBound( current_rec.dual_preprocessor_func_string ))
                
                Error( "dual_preprocessor_func and dual_preprocessor_func_string are mutually exclusive" );
                
            end;
            
            if (IsOperation( current_rec.dual_preprocessor_func ) || IsKernelFunction( current_rec.dual_preprocessor_func ))
                
                current_rec.dual_preprocessor_func_string = NameFunction( current_rec.dual_preprocessor_func );
                
            else
                
                current_rec.dual_preprocessor_func_string = StringGAP( current_rec.dual_preprocessor_func );
                
            end;
            
        end;
        
        if (@IsBound( current_rec.dual_postprocessor_func ))
            
            if (@IsBound( current_rec.dual_postprocessor_func_string ))
                
                Error( "dual_postprocessor_func and dual_postprocessor_func_string are mutually exclusive" );
                
            end;
            
            if (IsOperation( current_rec.dual_postprocessor_func ) || IsKernelFunction( current_rec.dual_postprocessor_func ))
                
                current_rec.dual_postprocessor_func_string = NameFunction( current_rec.dual_postprocessor_func );
                
            else
                
                current_rec.dual_postprocessor_func_string = StringGAP( current_rec.dual_postprocessor_func );
                
            end;
            
        end;
        
        func = ValueGlobal( current_recname );
        
        if (IsOperation( func ))
            
            current_rec.operation = func;
            
        elseif (IsFunction( func ))
            
            current_rec.operation = ValueGlobal( @Concatenation( current_recname, "Op" ) );
            
        else
            
            Error( "`ValueGlobal( current_recname )` is neither an operation nor a function" );
            
        end;
        
        if (@not @IsBound( current_rec.input_arguments_names ))
            
            current_rec.input_arguments_names = @Concatenation( [ "cat" ], List( (2):(Length( current_rec.filter_list )), i -> @Concatenation( "arg", StringGAP( i ) ) ) );
            
        end;
        
        if (current_rec.input_arguments_names[1] != "cat")
            
            Error( "the category argument must always be called \"cat\", please adjust the method record entry of ", current_recname );
            
        end;
        
        if (@not ForAll( current_rec.input_arguments_names, x -> IsString( x ) ))
            
            Error( "the entries of input_arguments_names must be strings, please adjust the method record entry of ", current_recname );
            
        end;
        
        if (@not IsDuplicateFreeList( current_rec.input_arguments_names ))
            
            Error( "input_arguments_names must be duplicate free, please adjust the method record entry of ", current_recname );
            
        end;
        
        if (ForAll( current_rec.filter_list, x -> x in [ "element_of_commutative_ring_of_linear_structure", "integer", "nonneg_integer_or_infinity", "category", "object", "object_in_range_category_of_homomorphism_structure", "list_of_objects" ] ))
            
            if (@not @IsBound( current_rec.compatible_with_congruence_of_morphisms ))
                
                current_rec.compatible_with_congruence_of_morphisms = true;
                
            end;
            
            if (current_rec.compatible_with_congruence_of_morphisms != true)
                
                Error( current_recname, " does not depend on morphisms but is still marked as not compatible with the congruence of morphisms" );
                
            end;
            
        end;
        
    end;
    
    # detect With(out)Given pairs
    for current_recname in recnames
        
        current_rec = record[current_recname];
        
        if (@IsBound( current_rec.with_given_object_position ))
            
            if (PositionSublist( current_recname, "WithGiven" ) != fail)
                
                Error( "WithGiven operations must NOT have the component with_given_object_position set, please adjust the method record entry of ", current_recname );
                
            end;
            
            without_given_name = current_recname;
            
            with_given_prefix = @Concatenation( without_given_name, "WithGiven" );
            
            with_given_names = Filtered( recnames, x -> StartsWith( x, with_given_prefix ) );
            
            if (Length( with_given_names ) != 1)
                
                Error( "Could not find unique WithGiven version for ", without_given_name );
                
            end;
            
            with_given_name = with_given_names[1];
            
            without_given_rec = record[without_given_name];
            
            with_given_object_position = without_given_rec.with_given_object_position;
            
            object_name = ReplacedString( with_given_name, with_given_prefix, "" );
            
            # generate output_source_getter_string resp. output_range_getter_string automatically if possible
            if (object_name in recnames)
                
                object_filter_list = record[object_name].filter_list;
                
                if (with_given_object_position == "Source")
                    
                    if (@not @IsBound( without_given_rec.output_source_getter_string ))
                        
                        without_given_rec.output_source_getter_string = @Concatenation( object_name, "( ", JoinStringsWithSeparator( without_given_rec.input_arguments_names[(1):(Length( object_filter_list ))], ", " ), " )" );
                        without_given_rec.output_source_getter_preconditions = [ [ object_name, 1 ] ];
                        
                    end;
                    
                end;
                
                if (with_given_object_position == "Range")
                    
                    if (@not @IsBound( without_given_rec.output_range_getter_string ))
                        
                        without_given_rec.output_range_getter_string = @Concatenation( object_name, "( ", JoinStringsWithSeparator( without_given_rec.input_arguments_names[(1):(Length( object_filter_list ))], ", " ), " )" );
                        without_given_rec.output_range_getter_preconditions = [ [ object_name, 1 ] ];
                        
                    end;
                    
                end;
                
            end;
            
            # plausibility checks for without_given_rec
            if (with_given_object_position in [ "Source", "both" ])
                
                if (@not @IsBound( without_given_rec.output_source_getter_string ))
                    
                    Error( "This is a WithoutGiven record, but output_source_getter_string is not set. This is not supported." );
                    
                end;
                
            end;
            
            if (with_given_object_position in [ "Range", "both" ])
                
                if (@not @IsBound( without_given_rec.output_range_getter_string ))
                    
                    Error( "This is a WithoutGiven record, but output_range_getter_string is not set. This is not supported." );
                    
                end;
                
            end;
            
            if (@not without_given_rec.return_type in [ "morphism", "morphism_in_range_category_of_homomorphism_structure" ])
                
                Error( "This is a WithoutGiven record, but return_type is neither \"morphism\" nor \"morphism_in_range_category_of_homomorphism_structure\". This is not supported." );
                
            end;
            
            # generate with_given_rec
            if (without_given_rec.return_type == "morphism")
                
                with_given_object_filter = "object";
                
            elseif (without_given_rec.return_type == "morphism_in_range_category_of_homomorphism_structure")
                
                with_given_object_filter = "object_in_range_category_of_homomorphism_structure";
                
            else
                
                Error( "this should never happen" );
                
            end;
            
            if (with_given_object_position == "Source")
                
                given_source_argument_name = Last( record[with_given_name].input_arguments_names );
                
            elseif (with_given_object_position == "Range")
                
                given_range_argument_name = Last( record[with_given_name].input_arguments_names );
                
            else
                
                given_source_argument_name = record[with_given_name].input_arguments_names[2];
                given_range_argument_name = Last( record[with_given_name].input_arguments_names );
                
            end;
            
            with_given_rec = @rec(
                return_type = without_given_rec.return_type,
            );
            
            if (with_given_object_position == "Source")
                
                with_given_rec.filter_list = @Concatenation( without_given_rec.filter_list, [ with_given_object_filter ] );
                with_given_rec.input_arguments_names = @Concatenation( without_given_rec.input_arguments_names, [ given_source_argument_name ] );
                with_given_rec.output_source_getter_string = given_source_argument_name;
                
                if (@IsBound( without_given_rec.output_range_getter_string ))
                    
                    with_given_rec.output_range_getter_string = without_given_rec.output_range_getter_string;
                    
                end;
                
                if (@IsBound( without_given_rec.output_range_getter_preconditions ))
                    
                    with_given_rec.output_range_getter_preconditions = without_given_rec.output_range_getter_preconditions;
                    
                end;
                
            elseif (with_given_object_position == "Range")
                
                with_given_rec.filter_list = @Concatenation( without_given_rec.filter_list, [ with_given_object_filter ] );
                with_given_rec.input_arguments_names = @Concatenation( without_given_rec.input_arguments_names, [ given_range_argument_name ] );
                with_given_rec.output_range_getter_string = given_range_argument_name;
                
                if (@IsBound( without_given_rec.output_source_getter_string ))
                    
                    with_given_rec.output_source_getter_string = without_given_rec.output_source_getter_string;
                    
                end;
                
                if (@IsBound( without_given_rec.output_source_getter_preconditions ))
                    
                    with_given_rec.output_source_getter_preconditions = without_given_rec.output_source_getter_preconditions;
                    
                end;
                
            elseif (with_given_object_position == "both")
                
                with_given_rec.filter_list = @Concatenation(
                    [ without_given_rec.filter_list[1] ],
                    [ with_given_object_filter ],
                    without_given_rec.filter_list[(2):(Length( without_given_rec.filter_list ))],
                    [ with_given_object_filter ]
                );
                with_given_rec.input_arguments_names = @Concatenation(
                    [ without_given_rec.input_arguments_names[1] ],
                    [ given_source_argument_name ],
                    without_given_rec.input_arguments_names[(2):(Length( without_given_rec.input_arguments_names ))],
                    [ given_range_argument_name ]
                );
                
                with_given_rec.output_source_getter_string = given_source_argument_name;
                with_given_rec.output_range_getter_string = given_range_argument_name;
                
            else
                
                Error( "this should never happen" );
                
            end;
            
            CAP_INTERNAL_IS_EQUAL_FOR_METHOD_RECORD_ENTRIES( record, with_given_name, with_given_rec; subset_only = true );
            
            # now enhance the actual with_given_rec
            with_given_rec = record[with_given_name];
            
            if (@IsBound( without_given_rec.pre_function ) && @not @IsBound( with_given_rec.pre_function ))
                with_given_rec.pre_function = CAP_INTERNAL_PREPARE_INHERITED_PRE_FUNCTION( record[without_given_name].pre_function, with_given_object_position == "both" );
            end;
            
            if (@IsBound( without_given_rec.pre_function_full ) && @not @IsBound( with_given_rec.pre_function_full ))
                with_given_rec.pre_function_full = CAP_INTERNAL_PREPARE_INHERITED_PRE_FUNCTION( record[without_given_name].pre_function_full, with_given_object_position == "both" );
            end;
            
            with_given_rec.is_with_given = true;
            with_given_rec.with_given_without_given_name_pair = [ without_given_name, with_given_name ];
            without_given_rec.with_given_without_given_name_pair = [ without_given_name, with_given_name ];
            
            if (object_name in recnames)
                
                if (with_given_object_position == "both")
                    
                    Error( "with_given_object_position is \"both\", but the WithGiven name suggests that only a single object of name ", object_name, " is given. This is not supported." );
                    
                end;
                
                with_given_rec.with_given_object_name = object_name;
                
                object_filter_list = record[object_name].filter_list;
                
                if (with_given_object_position == "Source")
                    
                    if (@not StartsWith( without_given_rec.output_source_getter_string, object_name ))
                        
                        Error( "the output_source_getter_string of the WithoutGiven record does not call the detected object ", object_name );
                        
                    end;
                    
                end;
                
                if (with_given_object_position == "Range")
                    
                    if (@not StartsWith( without_given_rec.output_range_getter_string, object_name ))
                        
                        Error( "the output_range_getter_string of the WithoutGiven record does not call the detected object ", object_name );
                        
                    end;
                    
                end;
                
                if (@not StartsWith( without_given_rec.filter_list, object_filter_list ))
                    
                    Error( "the object arguments must be the first arguments of the without given method, but the corresponding filters do not match" );
                    
                end;
                
                if (@not @IsBound( without_given_rec.redirect_function ))
                    
                    if (Length( record[without_given_name].filter_list ) + 1 != Length( record[with_given_name].filter_list ))
                        
                        Display( @Concatenation(
                            "WARNING: You seem to be relying on automatically installed redirect functions. ",
                            "For this, the with given method must have exactly one additional argument compared to the without given method. ",
                            "This is not the case, so no automatic redirect function will be installed. ",
                            "Install a custom redirect function to prevent this warning."
                        ) );
                        
                    else
                        
                        without_given_rec.redirect_function = CAP_INTERNAL_CREATE_REDIRECTION( without_given_name, with_given_name, object_name, object_filter_list, (1):(Length( object_filter_list )) );
                        
                    end;
                    
                end;
                
                if (@not @IsBound( without_given_rec.post_function ))
                    
                    without_given_rec.post_function = CAP_INTERNAL_CREATE_POST_FUNCTION( with_given_object_position, object_name, object_filter_list, (1):(Length( object_filter_list )) );
                    
                end;
                
            end;
            
        end;
        
    end;
    
    # loop after detecting With(out)Given pairs
    for current_recname in recnames
        
        current_rec = record[current_recname];
        
        if (@IsBound( current_rec.dual_with_given_objects_reversed ) && current_rec.dual_with_given_objects_reversed)
            
            if (@not current_rec.is_with_given)
                
                Error( "dual_with_given_objects_reversed may only be set for with given records" );
                
            end;
            
            without_given_rec = record[current_rec.with_given_without_given_name_pair[1]];
            
            with_given_object_position = without_given_rec.with_given_object_position;
            
            if (with_given_object_position != "both")
                
                Error( "dual_with_given_objects_reversed may only be set if both source and range are given" );
                
            end;
            
        end;
        
        # set `output_source_getter` and `output_range_getter`
        if (@IsBound( current_rec.output_source_getter_string ))
            
            current_rec.output_source_getter = EvalString( ReplacedStringViaRecord(
                "( arguments... ) -> getter",
                @rec(
                    arguments = current_rec.input_arguments_names,
                    getter = current_rec.output_source_getter_string,
                )
            ) );
            
            if (current_rec.output_source_getter_string in current_rec.input_arguments_names)
                
                if (@not @IsBound( current_rec.output_source_getter_preconditions ))
                    
                    current_rec.output_source_getter_preconditions = [ ];
                    
                end;
                
                if (@not IsEmpty( current_rec.output_source_getter_preconditions ))
                    
                    Error( "<current_rec.output_source_getter_preconditions> does not match the automatically detected value" );
                    
                end;
                
            end;
            
            #= comment for Julia
            if (@IsBound( current_rec.output_source_getter_preconditions ))
                
                if (ForAny( current_rec.output_source_getter_preconditions, x -> IsList( x ) && Length( x ) == 3 ))
                    
                    Print( "WARNING: preconditions in other categories are not yet supported, please report this using the CAP_projects's issue tracker.\n" );
                    
                end;
                
                if (ForAny( current_rec.output_source_getter_preconditions, x -> !(IsList( x )) || Length( x ) != 2 || !(IsString( x[1] )) || @not IsInt( x[2] ) ))
                    
                    Error( "Preconditions must be pairs of names of CAP operations and integers." );
                    
                end;
                
                collected_list = CAP_INTERNAL_FIND_APPEARANCE_OF_SYMBOL_IN_FUNCTION(
                        current_rec.output_source_getter,
                        @Concatenation( recnames, RecNames( CAP_INTERNAL_METHOD_NAME_RECORD ) ),
                        2,
                        CAP_INTERNAL_METHOD_RECORD_REPLACEMENTS,
                        @rec( )
                );
                
                @Assert( 0, ForAll( collected_list, x -> Length( x ) == 3 && x[3] == fail ) );
                
                preconditions = SetGAP( List( collected_list, x -> [ x[1], x[2] ] ) );
                
                if (SetGAP( current_rec.output_source_getter_preconditions ) != preconditions)
                    
                    Error( "output_source_getter_preconditions of ", current_recname, " is ", current_rec.output_source_getter_preconditions, " but expected ", preconditions );
                    
                end;
                
            end;
            # =#
            
            if (@IsBound( current_rec.output_source_getter_preconditions ))
                
                can_always_compute_output_source_getter = IsEmpty( current_rec.output_source_getter_preconditions );
                
                if (@IsBound( current_rec.can_always_compute_output_source_getter ))
                    
                    if (current_rec.can_always_compute_output_source_getter != can_always_compute_output_source_getter)
                        
                        Error( "<current_rec.can_always_compute_output_source_getter> does not match the automatically detected value" );
                        
                    end;
                    
                else
                    
                    current_rec.can_always_compute_output_source_getter = can_always_compute_output_source_getter;
                    
                end;
                
            end;
            
        end;
        
        if (@IsBound( current_rec.output_range_getter_string ))
            
            current_rec.output_range_getter = EvalString( ReplacedStringViaRecord(
                "( arguments... ) -> getter",
                @rec(
                    arguments = current_rec.input_arguments_names,
                    getter = current_rec.output_range_getter_string,
                )
            ) );
            
            if (current_rec.output_range_getter_string in current_rec.input_arguments_names)
                
                if (@not @IsBound( current_rec.output_range_getter_preconditions ))
                    
                    current_rec.output_range_getter_preconditions = [ ];
                    
                end;
                
                if (@not IsEmpty( current_rec.output_range_getter_preconditions ))
                    
                    Error( "<current_rec.output_range_getter_preconditions> does not match the automatically detected value" );
                    
                end;
                
            end;
            
            #= comment for Julia
            if (@IsBound( current_rec.output_range_getter_preconditions ))
                
                if (ForAny( current_rec.output_range_getter_preconditions, x -> IsList( x ) && Length( x ) == 3 ))
                    
                    Print( "WARNING: preconditions in other categories are not yet supported, please report this using the CAP_projects's issue tracker.\n" );
                    
                end;
                
                if (ForAny( current_rec.output_range_getter_preconditions, x -> !(IsList( x )) || Length( x ) != 2 || !(IsString( x[1] )) || @not IsInt( x[2] ) ))
                    
                    Error( "Preconditions must be pairs of names of CAP operations and integers." );
                    
                end;
                
                collected_list = CAP_INTERNAL_FIND_APPEARANCE_OF_SYMBOL_IN_FUNCTION(
                        current_rec.output_range_getter,
                        @Concatenation( recnames, RecNames( CAP_INTERNAL_METHOD_NAME_RECORD ) ),
                        2,
                        CAP_INTERNAL_METHOD_RECORD_REPLACEMENTS,
                        @rec( )
                );
                
                @Assert( 0, ForAll( collected_list, x -> Length( x ) == 3 && x[3] == fail ) );
                
                preconditions = SetGAP( List( collected_list, x -> [ x[1], x[2] ] ) );
                
                if (SetGAP( current_rec.output_range_getter_preconditions ) != preconditions)
                    
                    Error( "output_range_getter_preconditions of ", current_recname, " is ", current_rec.output_range_getter_preconditions, " but expected ", preconditions );
                    
                end;
                
            end;
            # =#
            
            if (@IsBound( current_rec.output_range_getter_preconditions ))
                
                can_always_compute_output_range_getter = IsEmpty( current_rec.output_range_getter_preconditions );
                
                if (@IsBound( current_rec.can_always_compute_output_range_getter ))
                    
                    if (current_rec.can_always_compute_output_range_getter != can_always_compute_output_range_getter)
                        
                        Error( "<current_rec.can_always_compute_output_range_getter> does not match the automatically detected value" );
                        
                    end;
                    
                else
                    
                    current_rec.can_always_compute_output_range_getter = can_always_compute_output_range_getter;
                    
                end;
                
            end;
            
        end;
        
        if (current_rec.return_type == "object")
            current_rec.add_value_to_category_function = AddObject;
        elseif (current_rec.return_type == "morphism")
            current_rec.add_value_to_category_function = AddMorphism;
        elseif (current_rec.return_type == "twocell")
            current_rec.add_value_to_category_function = AddTwoCell;
        else
            current_rec.add_value_to_category_function = ReturnTrue;
        end;
        
    end;
    
    CAP_INTERNAL_FIND_OPPOSITE_PROPERTY_PAIRS_IN_METHOD_NAME_RECORD( record );
    
end );

##
@InstallGlobalFunction( CAP_INTERNAL_GENERATE_DECLARATIONS_AND_INSTALLATIONS_FROM_METHOD_NAME_RECORD,
  function ( record, package_name, filename_prefix, chapter_name, section_name )
    local recnames, package_info, gd_output_string, gi_output_string, current_string, current_recname, current_rec, without_given_name, with_given_name, without_given_rec, with_given_rec, without_given_arguments_names, with_given_arguments_names, with_given_object_position, with_given_arguments_strings, additional_preconditions, x, pos, preconditions_string, gd_filename, gi_filename, output_path;
    
    #= comment for Julia
    
    recnames = SortedList( RecNames( record ) );
    
    package_info = First( PackageInfo( package_name ) );
    
    if (package_info == fail)
        
        Error( "could not find package info" );
        
    end;
    
    gd_output_string = "";
    gi_output_string = "";
    
    ## declarations
    
    # the space between # and ! prevents AutoDoc from parsing these strings and is removed below
    current_string = ReplacedStringViaRecord(
"""# SPDX-License-Identifier: GPL-2.0-or-later
# package_name: package_subtitle
#
# Declarations
#
# THIS FILE IS AUTOMATICALLY GENERATED, SEE CAP_project/CAP/gap/MethodRecordTools.gi

# ! @Chapter chapter_name

# ! @Section section_name
""",
        @rec(
            package_name = package_name,
            package_subtitle = package_info.Subtitle,
            chapter_name = chapter_name,
            section_name = section_name,
        )
    );
    
    # see comment above
    current_string = ReplacedString( current_string, "# !", "#!" );
    
    gd_output_string = @Concatenation( gd_output_string, current_string );
    
    ## implementations
    
    current_string = ReplacedStringViaRecord(
"""# SPDX-License-Identifier: GPL-2.0-or-later
# package_name: package_subtitle
#
# Implementations
#
# THIS FILE IS AUTOMATICALLY GENERATED, SEE CAP_project/CAP/gap/MethodRecordTools.gi
""",
        @rec(
            package_name = package_name,
            package_subtitle = package_info.Subtitle,
        )
    );
    
    gi_output_string = @Concatenation( gi_output_string, current_string );
    
    for current_recname in recnames
        
        current_rec = record[current_recname];
        
        ## declarations
        
        # the space between # and ! prevents AutoDoc from parsing these strings and is removed below
        current_string = ReplacedStringViaRecord(
"""
# ! @BeginGroup
# ! @Description
# ! The arguments are a category $C$ and a function $F$.
# ! This operation adds the given function $F$
# ! to the category for the basic operation `function_name`.
# ! Optionally, a weight (default: 100) can be specified which should roughly correspond
# ! to the computational complexity of the function (lower weight == less complex == faster execution).
# ! $F: ( input_arguments... ) \mapsto \mathtt[function_name](input_arguments...)$.
# ! @Returns nothing
# ! @Arguments C, F
@DeclareOperation( "Addfunction_name",
                  [ IsCapCategory, IsFunction ] );

# ! @Arguments C, F, weight
@DeclareOperation( "Addfunction_name",
                  [ IsCapCategory, IsFunction, IsInt ] );
# ! @EndGroup

""",
            @rec(
                function_name = current_recname,
                input_arguments = current_rec.input_arguments_names[(2):(Length( current_rec.input_arguments_names ))],
            )
        );
        
        # see comment above
        current_string = ReplacedString( current_string, "# !", "#!" );
        
        gd_output_string = @Concatenation( gd_output_string, current_string );
        
        ## implementations
        
        current_string = ReplacedStringViaRecord(
"""
## function_name
@InstallMethod( Addfunction_name,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    AddCapOperation( "function_name", category, func, -1 );
    
end );

@InstallMethod( Addfunction_name,
               [ IsCapCategory, IsFunction, IsInt ],
               
    @FunctionWithNamedArguments(
        [
            [ "IsPrecompiledDerivation", false ],
        ],
        function( CAP_NAMED_ARGUMENTS, category, func, weight )
            
            AddCapOperation( "function_name", category, func, weight; IsPrecompiledDerivation = IsPrecompiledDerivation );
            
        end
    )
);
""",
            @rec(
                function_name = current_recname,
                input_arguments = current_rec.input_arguments_names[(2):(Length( current_rec.input_arguments_names ))],
            )
        );
        
        gi_output_string = @Concatenation( gi_output_string, current_string );
        
        ## WithGiven derivations
        if (current_rec.is_with_given)
            
            without_given_name = current_rec.with_given_without_given_name_pair[1];
            with_given_name = current_rec.with_given_without_given_name_pair[2];
            
            without_given_rec = record[without_given_name];
            with_given_rec = record[with_given_name];
            
            without_given_arguments_names = without_given_rec.input_arguments_names;
            with_given_arguments_names = with_given_rec.input_arguments_names;
            
            with_given_object_position = without_given_rec.with_given_object_position;
            
            current_string = ReplacedStringViaRecord(
"""
AddDerivationToCAP( with_given_name,
                    "with_given_name by calling without_given_name with the WithGiven argument(s) dropped",
                    [
                        [ without_given_name, 1 ],
                    ],
  function( with_given_arguments... )
    
    return without_given_name( without_given_arguments... );
        
end; is_with_given_derivation = true );
""",
                @rec(
                    with_given_name = with_given_name,
                    without_given_name = without_given_name,
                    with_given_arguments = with_given_arguments_names,
                    without_given_arguments = without_given_arguments_names,
                )
            );
            
            gi_output_string = @Concatenation( gi_output_string, current_string );
            
            if (with_given_object_position == "Source")
                
                with_given_arguments_strings = @Concatenation( without_given_arguments_names, [ without_given_rec.output_source_getter_string ] );
                
                if (@not @IsBound( without_given_rec.output_source_getter_preconditions ))
                    
                    Print( "WARNING: Cannot install with given derivation pair for ", without_given_name, " because <without_given_rec.output_source_getter_preconditions> is not set.\n" );
                    return;
                    
                end;
                
                additional_preconditions = without_given_rec.output_source_getter_preconditions;
                
            elseif (with_given_object_position == "Range")
                
                with_given_arguments_strings = @Concatenation( without_given_arguments_names, [ without_given_rec.output_range_getter_string ] );
                
                if (@not @IsBound( without_given_rec.output_range_getter_preconditions ))
                    
                    Print( "WARNING: Cannot install with given derivation pair for ", without_given_name, " because <without_given_rec.output_range_getter_preconditions> is not set.\n" );
                    return;
                    
                end;
                
                additional_preconditions = without_given_rec.output_range_getter_preconditions;
                
            elseif (with_given_object_position == "both")
                
                with_given_arguments_strings = @Concatenation(
                    [ without_given_arguments_names[1] ],
                    [ without_given_rec.output_source_getter_string ],
                    without_given_arguments_names[(2):(Length( without_given_arguments_names ))],
                    [ without_given_rec.output_range_getter_string ]
                );
                
                if (@not @IsBound( without_given_rec.output_source_getter_preconditions ))
                    
                    Print( "WARNING: Cannot install with given derivation pair for ", without_given_name, " because <without_given_rec.output_source_getter_preconditions> is not set.\n" );
                    return;
                    
                end;
                
                if (@not @IsBound( without_given_rec.output_range_getter_preconditions ))
                    
                    Print( "WARNING: Cannot install with given derivation pair for ", without_given_name, " because <without_given_rec.output_range_getter_preconditions> is not set.\n" );
                    return;
                    
                end;
                
                # merge output_source_getter_preconditions and output_range_getter_preconditions
                additional_preconditions = without_given_rec.output_source_getter_preconditions;
                
                for x in without_given_rec.output_range_getter_preconditions
                    
                    pos = PositionProperty( additional_preconditions, y -> y[1] == x[1] );
                    
                    if (pos == fail)
                        
                        Add( additional_preconditions, x );
                        
                    else
                        
                        additional_preconditions[pos][2] = additional_preconditions[pos][2] + x[2];
                        
                    end;
                    
                end;
                
            else
                
                Error( "this should never happen" );
                
            end;
            
            preconditions_string = @Concatenation( "[ ", with_given_name, ", 1 ]" );
            
            for x in additional_preconditions
                
                Append( preconditions_string, @Concatenation( ",\n                        [ ", x[1], ", ", StringGAP( x[2] ), " ]" ) );
                
            end;
            
            current_string = ReplacedStringViaRecord(
"""
AddDerivationToCAP( without_given_name,
                    "without_given_name by calling with_given_name with the WithGiven object(s)",
                    [
                        preconditions_string,
                    ],
  function( without_given_arguments... )
    
    return with_given_name( with_given_arguments... );
    
end; is_with_given_derivation = true );
""",
                @rec(
                    without_given_name = without_given_name,
                    with_given_name = with_given_name,
                    preconditions_string = preconditions_string,
                    without_given_arguments = without_given_arguments_names,
                    with_given_arguments = with_given_arguments_strings,
                )
            );
            
            gi_output_string = @Concatenation( gi_output_string, current_string );
            
        end;
        
        
    end;
    
    ## declarations
    
    gd_filename = @Concatenation( filename_prefix, "Declarations.autogen.gd" );
    
    if (!(IsExistingFileInPackageForHomalg( package_name, gd_filename )) || gd_output_string != ReadFileFromPackageForHomalg( package_name, gd_filename ))
        
        output_path = Filename( DirectoryTemporary( ), gd_filename );
        
        WriteFileForHomalg( output_path, gd_output_string );
        
        Display( @Concatenation(
            "WARNING: The file ", gd_filename, " in package ", package_name, " differs from the automatically generated one. ",
            "You can view the automatically generated file at the following path: ",
            output_path
        ) );
        
    end;
    
    ## implementations
    
    gi_filename = @Concatenation( filename_prefix, "Installations.autogen.gi" );
    
    if (!(IsExistingFileInPackageForHomalg( package_name, gi_filename )) || gi_output_string != ReadFileFromPackageForHomalg( package_name, gi_filename ))
        
        output_path = Filename( DirectoryTemporary( ), gi_filename );
        
        WriteFileForHomalg( output_path, gi_output_string );
        
        Display( @Concatenation(
            "WARNING: The file ", gi_filename, " in package ", package_name, " differs from the automatically generated one. ",
            "You can view the automatically generated file at the following path: ",
            output_path
        ) );
        
    end;
    # =#
    
end );

@BindGlobal( "CAP_INTERNAL_METHOD_NAME_RECORDS_BY_PACKAGE", @rec( ) );

##
@InstallGlobalFunction( CAP_INTERNAL_REGISTER_METHOD_NAME_RECORD_OF_PACKAGE,
  function ( record, package_name )
    local recname;
    
    if (@not @IsBound( CAP_INTERNAL_METHOD_NAME_RECORDS_BY_PACKAGE[package_name] ))
        
        CAP_INTERNAL_METHOD_NAME_RECORDS_BY_PACKAGE[package_name] = @rec( );
        
    end;
    
    for recname in RecNames( record )
        
        if (@IsBound( CAP_INTERNAL_METHOD_NAME_RECORDS_BY_PACKAGE[package_name][recname] ))
            
            Error( recname, " is already registered for this package" );
            
        end;
        
        CAP_INTERNAL_METHOD_NAME_RECORDS_BY_PACKAGE[package_name][recname] = record[recname];
        
    end;
    
end );

##
@InstallGlobalFunction( CAP_INTERNAL_GENERATE_DOCUMENTATION_FOR_CATEGORY_INSTANCES,
  function ( subsections, package_name, filename, chapter_name, section_name )
    local output_string, package_info, current_string, transitively_needed_other_packages, parent_index, subsection, category, subsection_title, operations, bookname, info, label, match, nr, res, test_string, test_string_legacy, output_path, i, name;
    
    output_string = "";
    
    package_info = First( PackageInfo( package_name ) );
    
    if (package_info == fail)
        
        Error( "could not find package info" );
        
    end;
    
    # the space between # and ! prevents AutoDoc from parsing these strings and is removed below
    current_string = ReplacedStringViaRecord(
"""# SPDX-License-Identifier: GPL-2.0-or-later
# package_name: package_subtitle
#
# Declarations
#
# THIS FILE IS AUTOMATICALLY GENERATED, SEE CAP_project/CAP/gap/MethodRecord.gi

# ! @Chapter chapter_name

# ! @Section section_name
""",
        @rec(
            package_name = package_name,
            package_subtitle = package_info.Subtitle,
            chapter_name = chapter_name,
            section_name = section_name,
        )
    );
    
    output_string = @Concatenation( output_string, current_string );
    
    # We do not want to include operations from optional dependencies because those might not be available.
    transitively_needed_other_packages = TransitivelyNeededOtherPackages( package_name );
    
    for i in (1):(Length( subsections ))
        
        subsection = subsections[i];
        
        @Assert( 0, IsList( subsection ) && Length( subsection ) in [ 2, 3 ] );
        
        category = subsection[1];
        subsection_title = subsection[2];
        
        if (Length( subsection ) != 3)
            subsection[3] = i - 1;
        end;
        
        parent_index = subsection[3];
        
        @Assert( 0, IsCapCategory( category ) );
        @Assert( 0, IsString( subsection_title ) );
        
        # the space between # and ! prevents AutoDoc from parsing these strings and is removed below
        
        current_string = @Concatenation( "\n# ! @Subsection ", subsection_title );
        output_string = @Concatenation( output_string, current_string );
        
        if (i == 1)
            
            operations = AsSortedList( ListInstalledOperationsOfCategory( category ) );
            
            Add( subsection, operations );
            
            current_string = "\n\n# ! The following CAP operations are supported:";
            
        else
            
            operations = ListInstalledOperationsOfCategory( category );
            
            if (@not IsSubset( operations, subsections[parent_index][4] ))
                
                Error( "the operations of the category", Name( subsections[i - 1][1] ), " are not a subset of the operations of the category ", Name( subsections[i][1] ) );
                
            end;
            
            Add( subsection, operations );
            
            operations = AsSortedList( Difference( operations, subsections[parent_index][4] ) );
            
            current_string = @Concatenation( "\n\n# ! Additional to the operations listed in “", subsections[parent_index][2], "” the following operations are supported:" );
            
        end;
        
        if (IsEmpty( operations ))
            
            Display( "WARNING: No operations found, skipping subection" );
            
        end;
        
        output_string = @Concatenation( output_string, current_string );
        
        for name in operations
            
            # find package name == bookname
            bookname = PackageOfCAPOperation( name );
            
            if (bookname == fail)
                
                Display( @Concatenation( "WARNING: Could not find package for CAP operation ", name, ", skipping." ) );
                continue;
                
            end;
            
            # skip operation if it comes from an optional dependency
            if (@not bookname in transitively_needed_other_packages)
                
                continue;
                
            end;
            
            # simulate GAPDoc's `ResolveExternalRef` to make sure we get a correct reference
            info = HELP_BOOK_INFO( bookname );
            
            if (info == fail)
                
                Error( "Could not get HELP_BOOK_INFO for book ", bookname, ". You probably have to execute `make doc` for the corresponding package." );
                
            end;
            
            if (IsOperation( ValueGlobal( name ) ))
                
                # the "for Is" makes sure we only match operations with a filter and not functions
                label = "for Is";
                
            else
                
                label = "";
                
            end;
            
            match = @Concatenation( HELP_GET_MATCHES( info, SIMPLE_STRING( @Concatenation( name, " (", label, ")" ) ), true ) );
            
            nr = 1;
            
            if (Length(match) < nr)
                
                Error( "Could not get HELP_GET_MATCHES for book ", bookname, ", operation ", name, ", and label ", SIMPLE_STRING( label ) );
                
            end;
            
            res = GetHelpDataRef(info, match[nr][2]);
            res[1] = SubstitutionSublist(res[1], " (not loaded): ", ": ", "one");
            
            if (IsOperation( ValueGlobal( name ) ))
                
                test_string = @Concatenation( bookname, ": ", name, " for Is" );
                # needed for GAPDoc < 1.6.5
                test_string_legacy = @Concatenation( bookname, ": ", name, " for is" );
                
                if (!(StartsWith( res[1], test_string ) || StartsWith( res[1], test_string_legacy )))
                    
                    Error( res[1], " does not start with ", test_string, ", matching wrong operation?" );
                    
                end;
                
            else
                
                test_string = @Concatenation( bookname, ": ", name );
                
                if (@not res[1] == test_string)
                    
                    Error( res[1], " is not equal to ", test_string, ", matching wrong function?" );
                    
                end;
                
            end;
            
            current_string = ReplacedStringViaRecord(
                "\n# ! * <Ref BookName=\"bookname\" Func=\"operation_name\" Label=\"label\" />", # GAPDoc does @not care if we use `Func` || `Oper` for external refs
                @rec(
                    bookname = bookname,
                    operation_name = name,
                    label = label,
                )
            );
            output_string = @Concatenation( output_string, current_string );
            
        end;
        
        output_string = @Concatenation( output_string, "\n" );
        
    end;
    
    # see comments above
    output_string = ReplacedString( output_string, "# !", "#!" );
    
    if (!(IsExistingFileInPackageForHomalg( package_name, filename )) || output_string != ReadFileFromPackageForHomalg( package_name, filename ))
        
        output_path = Filename( DirectoryTemporary( ), filename );
        
        WriteFileForHomalg( output_path, output_string );
        
        Display( @Concatenation(
            "WARNING: The file ", filename, " in package ", package_name, " differs from the automatically generated one. ",
            "You can view the automatically generated file at the following path: ",
            output_path
        ) );
        
    end;
    
end );
