
"""
`AbstractModule`

Um `AbstractModule` trata dos diferentes tipos de módulos
usados no túnel de vento. Um módulo corresponde ao software
necessário para executar um ensaio padrão. Um módulo
tem scripts de mediçao e processamento. Também tem os ambientes
necessários para executar o ensaio.

O módulo deve ter um campo `path` com a raíz da pasta, o campo `folders`
com as subpastas necessárias. O campo mais importante deve ser o campo
`module` que tem o repositório com os scripts.
"""
abstract type AbstractLabDaqModule <: AbstractLabDaqProject end


mutable struct LabDaqModule <: AbstractLabDaqModule
    "Arquivo de configuração do projeto"
    project::LabDaqProject
    name::String
    path::String
    folders::Dict{Symbol,String}
    toml::TDict
    repository::String
end


function LabDaqModule(project::LabDaqProject, name::Symbol, path::String,
                  toml, repository)
    

end









#projectpath
