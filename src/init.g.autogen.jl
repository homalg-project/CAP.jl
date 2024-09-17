# SPDX-License-Identifier: GPL-2.0-or-later
# CAP: Categories, Algorithms, Programming
#
# Reading the declaration part of the package.
#
## the CAP core
include( "gap/ToolsForCategories.gd.autogen.jl" );

include( "gap/CAP.gd.autogen.jl" );

include( "gap/Derivations.gd.autogen.jl" );

include( "gap/Finalize.gd.autogen.jl" );

include( "gap/MethodRecordTools.gd.autogen.jl" );

include( "gap/CategoryObjects.gd.autogen.jl" );

include( "gap/CategoryMorphisms.gd.autogen.jl" );

include( "gap/CategoryTwoCells.gd.autogen.jl" );

include( "gap/LimitConvenience.gd.autogen.jl" );

include( "gap/InstallAdds.gd.autogen.jl" );

#= comment for Julia
include( "gap/TheoremParser.gd.autogen.jl" );
# =#

include( "gap/LogicForCAP.gd.autogen.jl" );

include( "gap/ConstructiveCategoriesRecord.gd.autogen.jl" );

include( "gap/PrintingFunctions.gd.autogen.jl" );

include( "gap/PrepareFunctionsTools.gd.autogen.jl" );

# load tools required for the CAP library
include( "gap/ToolsForCategories.gi.autogen.jl" );

## the CAP library

## pre-defined CAP operations
include( "gap/CategoryObjectsOperations.gd.autogen.jl" );

include( "gap/CategoryMorphismsOperations.gd.autogen.jl" );

include( "gap/CategoryTwoCellsOperations.gd.autogen.jl" );

include( "gap/UniversalObjects.gd.autogen.jl" );

include( "gap/MethodRecordDeclarations.autogen.gd.autogen.jl" );

## pre-defined category constructors
include( "gap/OppositeCategory.gd.autogen.jl" );

include( "gap/ProductCategory.gd.autogen.jl" );

include( "gap/CategoriesCategory.gd.autogen.jl" );

include( "gap/CategoryConstructor.gd.autogen.jl" );

include( "gap/TerminalCategory.gd.autogen.jl" );

include( "gap/ReinterpretationOfCategory.gd.autogen.jl" );

include( "gap/WrapperCategory.gd.autogen.jl" );

include( "gap/DummyImplementations.gd.autogen.jl" );
