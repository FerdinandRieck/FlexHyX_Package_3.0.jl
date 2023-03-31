module FlexHyX_Package
    using LinearAlgebra, Plots, NLsolve, DifferentialEquations

    import Pkg
    import JSON
    using TerminalLoggers
    using Plots
    using DifferentialEquations
    using Dates
    using NLsolve
    using LinearAlgebra

    include("Komponenten/Batterie.jl")
    include("Komponenten/PV_Anlage.jl")
    include("Komponenten/Leistung.jl")
    include("DGL.jl")
    include("Glättung.jl")
    include("Solve_Netzwerk.jl")
    include("Plot_Sol.jl")
    include("Read_Netz.jl")
    include("Inzidenz.jl")
    include("Datenstruktur.jl")

    export solveNetzwerk
    export plotsol

    sol = solveNetzwerk()
    plotsol(sol)
end
