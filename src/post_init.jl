pop!(ModulesForEvaluationStack)
@Assert( 0, IsEmpty( ModulesForEvaluationStack ) )

function MultiplyWithElementOfCommutativeSemiringForMorphisms(C::IsCapCategory.abstract_type, r::Any, alpha::IsCapCategoryMorphism.abstract_type)
    semiring = CommutativeSemiringOfLinearCategory( C );
    return MultiplyWithElementOfCommutativeSemiringForMorphisms( C, semiring( r ), alpha );
end

##
## BigInt wrappers: delegate BigInt integer argument to the Int64 version.

# [ "category", "list_of_objects", "integer" ]
for op in [ :ProjectionInFactorOfDirectProduct, :InjectionOfCofactorOfCoproduct,
             :ProjectionInFactorOfDirectSum, :InjectionOfCofactorOfDirectSum ]
    @eval begin
        function $op( cat::IsCapCategory.abstract_type, objects::IsList.abstract_type, k::BigInt )
            return $op( cat, objects, Int( k ) )
        end
        function $op( objects::IsList.abstract_type, k::BigInt )
            return $op( objects, Int( k ) )
        end
    end
end

# [ "category", "list_of_objects", "integer", "object" ]
for op in [ :ProjectionInFactorOfDirectProductWithGivenDirectProduct, :InjectionOfCofactorOfCoproductWithGivenCoproduct,
             :ProjectionInFactorOfDirectSumWithGivenDirectSum, :InjectionOfCofactorOfDirectSumWithGivenDirectSum ]
    @eval begin
        function $op( cat::IsCapCategory.abstract_type, objects::IsList.abstract_type, k::BigInt, P::IsCapCategoryObject.abstract_type )
            return $op( cat, objects, Int( k ), P )
        end
        function $op( objects::IsList.abstract_type, k::BigInt, P::IsCapCategoryObject.abstract_type )
            return $op( objects, Int( k ), P )
        end
    end
end

# [ "category", "list_of_morphisms", "integer" ]
for op in [ :ProjectionInFactorOfFiberProduct, :InjectionOfCofactorOfPushout ]
    @eval begin
        function $op( cat::IsCapCategory.abstract_type, morphisms::IsList.abstract_type, k::BigInt )
            return $op( cat, morphisms, Int( k ) )
        end
        function $op( morphisms::IsList.abstract_type, k::BigInt )
            return $op( morphisms, Int( k ) )
        end
    end
end

# [ "category", "list_of_morphisms", "integer", "object" ]
for op in [ :ProjectionInFactorOfFiberProductWithGivenFiberProduct, :InjectionOfCofactorOfPushoutWithGivenPushout ]
    @eval begin
        function $op( cat::IsCapCategory.abstract_type, morphisms::IsList.abstract_type, k::BigInt, P::IsCapCategoryObject.abstract_type )
            return $op( cat, morphisms, Int( k ), P )
        end
        function $op( morphisms::IsList.abstract_type, k::BigInt, P::IsCapCategoryObject.abstract_type )
            return $op( morphisms, Int( k ), P )
        end
    end
end

# [ "category", "morphism", "list_of_objects", "integer" ]
for op in [ :ComponentOfMorphismIntoDirectProduct, :ComponentOfMorphismFromCoproduct,
             :ComponentOfMorphismIntoDirectSum, :ComponentOfMorphismFromDirectSum ]
    @eval begin
        function $op( cat::IsCapCategory.abstract_type, alpha::IsCapCategoryMorphism.abstract_type, objects::IsList.abstract_type, i::BigInt )
            return $op( cat, alpha, objects, Int( i ) )
        end
        function $op( alpha::IsCapCategoryMorphism.abstract_type, objects::IsList.abstract_type, i::BigInt )
            return $op( alpha, objects, Int( i ) )
        end
    end
end

## LaTeXOutput for Nemo ring types (moved from MatricesForHomalg)
LaTeXOutput( ::Nemo.ZZRing ) = "\\mathbb{Z}"
LaTeXOutput( ::Nemo.QQField ) = "\\mathbb{Q}"
