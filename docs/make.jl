using LabDaqConfig
using Documenter

DocMeta.setdocmeta!(LabDaqConfig, :DocTestSetup, :(using LabDaqConfig); recursive=true)

makedocs(;
    modules=[LabDaqConfig],
    authors="= <pjabardo@ipt.br> and contributors",
    sitename="LabDaqConfig.jl",
    format=Documenter.HTML(;
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
