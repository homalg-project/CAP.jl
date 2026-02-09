```jldoctest FilterIntersection
julia> using CAP

julia> @DeclareFilter("IsF1", IsCapCategory);

julia> @DeclareFilter("IsF2", IsCapCategory);

julia> @DeclareFilter("IsF3", IsCapCategory);

julia> @DeclareProperty("SatisfiesPropertyP1", IsCapCategory);

julia> @DeclareProperty("SatisfiesPropertyP2", IsCapCategory);

julia> @FilterIntersection(IsF1, SatisfiesPropertyP1);

julia> @FilterIntersection(IsF1, SatisfiesPropertyP1, SatisfiesPropertyP2);

julia> @FilterIntersection(IsF1, HasRangeCategoryOfHomomorphismStructure);

julia> @FilterIntersection(IsF2, SatisfiesPropertyP2);

julia> @DeclareFilterDispatchedOperation("TestOp", [IsCapCategory]);

julia> @InstallMethod(TestOp, [IsF1], obj -> "Method for IsF1");

julia> @InstallMethod(TestOp, [FilterIntersection(IsF1, SatisfiesPropertyP1)], obj -> "Method for IsF1 with Property P1");

julia> @InstallMethod(TestOp, [FilterIntersection(IsF1, SatisfiesPropertyP1, SatisfiesPropertyP2)], obj -> "Method for IsF1 with Properties P1 and P2");

julia> @InstallMethod(TestOp, [IsF2], obj -> "Method for IsF2");

julia> @InstallMethod(TestOp, [FilterIntersection(IsF2, SatisfiesPropertyP2)], obj -> "Method for IsF2 with Property P2");

julia> F1 = CreateCapCategory("F1 instance", IsF1, IsCapCategoryObject, IsCapCategoryMorphism, IsCapCategoryTwoCell);

julia> TestOp(F1)
"Method for IsF1"

julia> F1_P1 = CreateCapCategory("F1_P1 instance", IsF1_and_SatisfiesPropertyP1, IsCapCategoryObject, IsCapCategoryMorphism, IsCapCategoryTwoCell);

julia> TestOp(F1_P1)
"Method for IsF1 with Property P1"

julia> IsF1_and_SatisfiesPropertyP1( F1 )
false

julia> SetSatisfiesPropertyP1(F1, true)

julia> IsF1_and_SatisfiesPropertyP1( F1 )
true

julia> TestOp( F1 )
"Method for IsF1 with Property P1"

julia> IsF1_and_HasRangeCategoryOfHomomorphismStructure( F1 )
false

julia> SetRangeCategoryOfHomomorphismStructure( F1, F1 )

julia> IsF1_and_HasRangeCategoryOfHomomorphismStructure( F1 )
true

julia> @FilterIntersection(IsF1, IsF2)

julia> @FilterIntersection(IsF1, IsF2, IsF3)

julia> @InstallMethod(TestOp, [FilterIntersection(IsF1, IsF2)], obj -> "Method for IsF1_and_IsF2")

julia> @InstallMethod(TestOp, [FilterIntersection(IsF1, IsF2, IsF3)], obj -> "Method for IsF1_and_IsF2_and_IsF3")

julia> F12 = CreateCapCategory("F1_and_F2 instance", IsF1_and_IsF2, IsCapCategoryObject, IsCapCategoryMorphism, IsCapCategoryTwoCell)
F1_and_F2 instance

julia> TestOp(F12)
"Method for IsF1_and_IsF2"

julia> F123 = CreateCapCategory("IsF1_and_IsF2_and_IsF3 instance", IsF1_and_IsF2_and_IsF3, IsCapCategoryObject, IsCapCategoryMorphism, IsCapCategoryTwoCell)
IsF1_and_IsF2_and_IsF3 instance

julia> TestOp(F123)
"Method for IsF1_and_IsF2_and_IsF3"
```
