function SAVE_CAP_STATE()
	derivations_by_target = @rec()
	for recname in RecNames( CAP_INTERNAL_DERIVATION_GRAPH.derivations_by_target )
		derivations_by_target[recname] = ShallowCopy( CAP_INTERNAL_DERIVATION_GRAPH.derivations_by_target[recname] )
	end
	
	derivations_by_used_ops = @rec()
	for recname in RecNames( CAP_INTERNAL_DERIVATION_GRAPH.derivations_by_used_ops )
		derivations_by_used_ops[recname] = ShallowCopy( CAP_INTERNAL_DERIVATION_GRAPH.derivations_by_used_ops[recname] )
	end
	
	state = (
		CAP_INTERNAL_METHOD_NAME_RECORD = ShallowCopy( CAP_INTERNAL_METHOD_NAME_RECORD ),
		CAP_INTERNAL_METHOD_NAME_RECORDS_BY_PACKAGE = ShallowCopy( CAP_INTERNAL_METHOD_NAME_RECORDS_BY_PACKAGE ),
		CAP_INTERNAL_CATEGORICAL_PROPERTIES_LIST = ShallowCopy( CAP_INTERNAL_CATEGORICAL_PROPERTIES_LIST ),
		CAP_INTERNAL_CONSTRUCTIVE_CATEGORIES_RECORD = ShallowCopy( CAP_INTERNAL_CONSTRUCTIVE_CATEGORIES_RECORD ),
		CAP_INTERNAL_DERIVATION_GRAPH_operations = ShallowCopy( Operations( CAP_INTERNAL_DERIVATION_GRAPH ) ),
		CAP_INTERNAL_DERIVATION_GRAPH_derivations_by_target = derivations_by_target,
		CAP_INTERNAL_DERIVATION_GRAPH_derivations_by_used_ops = derivations_by_used_ops,
		CAP_INTERNAL_FINAL_DERIVATION_LIST = ShallowCopy( CAP_INTERNAL_FINAL_DERIVATION_LIST )
	)
end

function RESTORE_CAP_STATE(state)
	##
	for recname in RecNames( state.CAP_INTERNAL_METHOD_NAME_RECORD )
		
		if !(@IsBound( CAP_INTERNAL_METHOD_NAME_RECORD[recname] ))
			
			CAP_INTERNAL_METHOD_NAME_RECORD[recname] = state.CAP_INTERNAL_METHOD_NAME_RECORD[recname];
			
		end
		
	end
	
	##
	for recname in RecNames( state.CAP_INTERNAL_METHOD_NAME_RECORDS_BY_PACKAGE )
		
		if !(@IsBound( CAP_INTERNAL_METHOD_NAME_RECORDS_BY_PACKAGE[recname] ))
			
			CAP_INTERNAL_METHOD_NAME_RECORDS_BY_PACKAGE[recname] = state.CAP_INTERNAL_METHOD_NAME_RECORDS_BY_PACKAGE[recname];
			
		end
		
	end
	
	##
	for pair in state.CAP_INTERNAL_CATEGORICAL_PROPERTIES_LIST
		
		if !(pair in CAP_INTERNAL_CATEGORICAL_PROPERTIES_LIST )
			
			Add( CAP_INTERNAL_CATEGORICAL_PROPERTIES_LIST, pair );
			
		end
		
	end
	
	##
	for recname in RecNames( state.CAP_INTERNAL_CONSTRUCTIVE_CATEGORIES_RECORD )
		
		if !(@IsBound( CAP_INTERNAL_CONSTRUCTIVE_CATEGORIES_RECORD[recname] ))
			
			CAP_INTERNAL_CONSTRUCTIVE_CATEGORIES_RECORD[recname] = state.CAP_INTERNAL_CONSTRUCTIVE_CATEGORIES_RECORD[recname];
			
		end
		
	end
	
	##
	for operation in state.CAP_INTERNAL_DERIVATION_GRAPH_operations
		
		if !(operation in Operations( CAP_INTERNAL_DERIVATION_GRAPH ) )
			
			Add( Operations( CAP_INTERNAL_DERIVATION_GRAPH ), operation );
			
		end
		
	end
	
	##
	for recname in RecNames( state.CAP_INTERNAL_DERIVATION_GRAPH_derivations_by_target )
		
		if @IsBound( CAP_INTERNAL_DERIVATION_GRAPH.derivations_by_target[recname] )
			
			for derivation in state.CAP_INTERNAL_DERIVATION_GRAPH_derivations_by_target[recname]
				
				if !ForAny( CAP_INTERNAL_DERIVATION_GRAPH.derivations_by_target[recname], x -> x === derivation )
					
					Add( CAP_INTERNAL_DERIVATION_GRAPH.derivations_by_target[recname], derivation );
					
				end
				
			end
			
		else
			
			CAP_INTERNAL_DERIVATION_GRAPH.derivations_by_target[recname] = ShallowCopy( state.CAP_INTERNAL_DERIVATION_GRAPH_derivations_by_target[recname] )
			
		end
		
	end
	
	##
	for recname in RecNames( state.CAP_INTERNAL_DERIVATION_GRAPH_derivations_by_used_ops )
		
		if @IsBound( CAP_INTERNAL_DERIVATION_GRAPH.derivations_by_used_ops[recname] )
			
			for derivation in state.CAP_INTERNAL_DERIVATION_GRAPH_derivations_by_used_ops[recname]
				
				if !ForAny( CAP_INTERNAL_DERIVATION_GRAPH.derivations_by_used_ops[recname], x -> x === derivation )
					
					Add( CAP_INTERNAL_DERIVATION_GRAPH.derivations_by_used_ops[recname], derivation );
					
				end
				
			end
			
		else
			
			CAP_INTERNAL_DERIVATION_GRAPH.derivations_by_used_ops[recname] = ShallowCopy( state.CAP_INTERNAL_DERIVATION_GRAPH_derivations_by_used_ops[recname] )
			
		end
		
	end
	
	##
	for derivation in state.CAP_INTERNAL_FINAL_DERIVATION_LIST
		
		if !ForAny( CAP_INTERNAL_FINAL_DERIVATION_LIST, x -> x === derivation )
			
			Add( CAP_INTERNAL_FINAL_DERIVATION_LIST, derivation );
			
		end
		
	end
end
