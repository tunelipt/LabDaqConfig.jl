# Arquivos de configuração
export AbstractLabDaqProject, LabDaqProject, projectpath
export rootpath, projecttag, projectname
export LabDaqConfig, projectaddress, projectcoords, projectdescr
export projectclient, projectfile
export projecttoml, generateproject, loadproject, projectfolder
export workpath, outputpath, reportpath, scriptspath, processpath, measpath

import TOML

"""
`AbstractLabDaqConfig`

An abstract type that uses TOML 
"""
abstract type AbstractLabDaqConfig end
abstract type AbstractLabDaqProject <: AbstractLabDaqConfig end

const TDict = Dict{String,Any}
const Folders = Dict{Symbol,String}

const registered_modules = [
    :blpitot,  # Camada limite com Pitot Prandtl
    :blhw,     # Camada limite com fio quente
    :pressure] 

const default_folders = Dict(:output=>"output", :work=>"work",
                             :measurements=>"medidas", :scripts=>"scripts",
                             :process=>"process", :report=>"relatorio",
                             :modules=>"modules")

mutable struct TOMLConfig <: AbstractLabDaqConfig
    root::String
    toml::TDict
end

"""
`TOMLConfig(;file="filename")`
`TOMLConfig(;str="Contents of TOML File")`

Creates a `TOMLConfig` from a file, a string with the contents of a TOML file
or a previously read TOML file stored in `Dict{String,Any}` variable.

Every `TOMLConfig` has a root path that is used to build path names. If not provided,
it will try to use the directory 

"""
function TOMLConfig(;path=nothing, file=nothing, toml=nothing)

    if !isnothing(file)
        # Let's read and parse the file
        str = read(file, String)
        toml = TOML.parse(str)
        # Let's get the root path.
        if isnothing(path)
            # The path will be hardcoded to directory name where the file is located
            root = dirname(abspath(file))
        else
            if path=""
                # Current path
                root = pwd()
            else
                root = path
            end
        end
    elseif isa(toml, AbstractString)
        toml = TOML.parse(tom)
        if isnothing(path) || path=""
            root = pwd()
        else
            root = path
        end
    elseif isa(toml, Dict{String})
        if isnothing(path) || path=""
            root = pwd()
        else
            root = path
        end
    else
        error("Don't know what `toml` is! You should specify `file` or `toml`")
    end

    return TOMLConfig(root, toml)

end

mutable struct LabDaqProject <: AbstractLabDaqProject
    "Nome do empreendimento"
    name::String
    "Tag do projeto - nome base dos arquivos"
    tag::String
    "Descrição do empreendimento"
    descr::String
    "Endereço do empreendimento"
    address::String
    "Coordenadas do empreendimento (latitude, longitude, altitude)"
    coords::Tuple{Float64,Float64,Float64}
    "Contato/Cliente que solicitou o trabalho"
    client::String
    "Pasta raíz do projeto"
    path::String
    "Pastas de trabalho"
    folders::Dict{Symbol,String}
    "Módulos para realização e processamento dos dados de ensaio"
    modules::Vector{TDict}
    "Dicionário do toml"
    toml::TDict
    "Conteudo do arquivo do TOML"
    tomlstr::String
    "Nome do arquivo TOML"
    fname::String
end

function Base.show(io::IO, p::LabDaqProject)
    println(io, "Project: $(projectname(p))")
    println(io, "    tag: $(projecttag(p))")
    println(io, "    Address: $(projectaddress(p))")
    println(io, "    Description: $(projectdescr(p))")
    println(io, "    Modules:")
    for (i,m) in enumerate(p.modules)
        if haskey(m, "name")
            nn = m["name"]
        else
            nn = "????"
        end
        println(io, "      Module $i: $(nn)")
    end
    println(io, "    Folders:")
    for (k,v) in p.folders
        println(io, "      $(String(k)) -> $v")
    end
    
        
end



function parseprojecttoml(toml, path, tomlstr, fname)

    # Informações básicas sobre o projeto
    p = toml["project"]

    
    name = haskey(p, "name") ? p["name"] : ""
    tag = haskey(p, "tag") ? p["tag"] : "ensaio"
    descr = haskey(p, "descr") ? p["descr"] : ""
    address = haskey(p, "address") ? p["address"] : ""
    client = haskey(p, "client") ? p["client"] : ""
    
    if !haskey(p, "coords")
        coords = (0.0, 0.0, 0.0)
    else
        xx = p["coords"]
        if length(xx) == 2
            coords = (Float64(xx[1]), Float64(xx[2]), 0.0)
        else
            coords = (Float64(xx[1]), Float64(xx[2]), Float64(xx[3]))
        end
    end
    
    
    
    # Pastas de trabalho. Vamos começar com nomes padrão
    folders = copy(default_folders) 
                       
    if haskey(toml, "folders")
        for (k,v) in toml["folders"]
            k1 = Symbol(lowercase(k))
            folders[k1] = v
        end
    end
    
        
    # Módulos
    modules = TDict[]
    if haskey(toml, "modules")
        tmod = toml["modules"]
        if !isa(tmod, AbstractArray)
            tmod = [tmod]
        end
        for mm in tmod
            push!(modules, mm)
        end
    end
    

    tomlstr = ""  # Isto deve ser acertado quando gerar o projeto
    fname = "" # No
    
    project = WTProject(name, tag, descr, address, coords, client, path,
                        folders, modules, toml, tomlstr, fname)
    
    
end



function generateproject(tomlfile)
    
    project = loadproject(tomlfile)

    # Agora baixar as coisas e gerar as pastas necessárias
    
    return project
    
end        

function loadproject(tomlfile)
    tomlstr = read(tomlfile, String)
    fname = basename(tomlfile)
    path = dirname(tomlfile)
    
    toml = TOML.parse(tomlstr)

    # Agora vamos os arquivos 
    project = parseprojecttoml(toml, path, tomlstr, fname)
    return project
    
end

getindex(c::TOMLConfig, k) = c.toml[k]

project(c::WTProject) = c
project(c::AbstractWTProject) = c.project
projectname(c::AbstractWTProject) = project(c).name

projecttag(c::AbstractWTProject) = project(c).tag
projectpath(c::AbstractWTProject) = c.path
projectroot(c::AbstractWTProject) = project(c).path
projectfile(c::AbstractWTProject) = project(c).fname
projecttoml(c::AbstractWTProject) = project(c).toml
    
projectpath(c::AbstractWTProject, p...) = projectpath(projectpath(c), p...)

function projectpath(c::AbstractWTProject, folder::Symbol, p...;
                     file=true, build=false)

    root = projectpath(c)
    fld = projectfolder(c, folder)
    return projectpath(root, fld, p...; file=file, build=build)
end    

projectaddress(c::AbstractWTProject) = project(c).address
projectcoords(c::AbstractWTProject) = project(c).coords


projectfolder(c::AbstractWTProject, folder::Symbol) = c.folders[folder]
projectdescr(c::AbstractWTProject) = project(c).descr


function generateproject(project::AbstractWTProject)

    path = projectpath(project)

    if !isdir(path)
        mkdir(path)
    end

end

workpath(c::AbstractWTProject, p...; file=true, build=false) =
    projectpath(c, :work, p...; file=file, build=build)
outputpath(c::AbstractWTProject, p...; file=true, build=false) =
    projectpath(c, :output, p...; file=file, build=build)
reportpath(c::AbstractWTProject, p...; file=true, build=false) =
    projectpath(c, :report, p...; file=file, build=build)

scriptspath(c::AbstractWTProject, p...; file=true, build=false) =
    projectpath(c, :script, p...; file=file, build=build)
processpath(c::AbstractWTProject, p...; file=true, build=false) =
    projectpath(c, :process, p...; file=file, build=build)

measpath(c::AbstractWTProject, p...; file=true, build=false) =
    projectpath(c, :measdata, p...; file=file, build=build)


    
