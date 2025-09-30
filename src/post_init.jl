pop!(ModulesForEvaluationStack)
@Assert( 0, IsEmpty( ModulesForEvaluationStack ) )

function MultiplyWithElementOfCommutativeRingForMorphisms(C::IsCapCategory.abstract_type, r::Any, alpha::IsCapCategoryMorphism.abstract_type)
    ring = CommutativeRingOfLinearCategory( C );
    return MultiplyWithElementOfCommutativeRingForMorphisms( C, ring( r ), alpha );
end
