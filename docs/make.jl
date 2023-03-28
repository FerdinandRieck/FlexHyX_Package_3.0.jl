using FlexHyX_Package_3.0
using Documenter

DocMeta.setdocmeta!(FlexHyX_Package_3.0, :DocTestSetup, :(using FlexHyX_Package_3.0); recursive=true)

makedocs(;
    modules=[FlexHyX_Package_3.0],
    authors="Ferdinand Rieck <ferdinand.rieck@smail.emt.h-brs.de>",
    repo="https://github.com/FerdinandRieck/FlexHyX_Package_3.0.jl/blob/{commit}{path}#{line}",
    sitename="FlexHyX_Package_3.0.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
