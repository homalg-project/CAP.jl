pop!(ModulesForEvaluationStack)
@Assert( 0, IsEmpty( ModulesForEvaluationStack ) )

function MultiplyWithElementOfCommutativeSemiringForMorphisms(C::IsCapCategory.abstract_type, r::Any, alpha::IsCapCategoryMorphism.abstract_type)
    semiring = CommutativeSemiringOfLinearCategory( C );
    return MultiplyWithElementOfCommutativeSemiringForMorphisms( C, semiring( r ), alpha );
end
