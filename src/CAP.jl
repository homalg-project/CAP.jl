module CAP

@nospecialize

using AbstractAlgebra

include("gap_emulation.jl")

include("init.jl")

pop!(ModulesForEvaluationStack)
@Assert( 0, IsEmpty( ModulesForEvaluationStack ) )

end # module CAP
