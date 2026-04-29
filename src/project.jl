abstract type AbstractLabDaqProject <: AbstractLabDaqConf end

mutable struct LabDaqProject <: AbstractLabDaqProject
    "Project name"
    name::String
    "Project tag. Used in building filenames"
    tag::String
    "Description"
    descr::String
    "Project address"
    address::String
    "Project coordinates (latitude, longitude, altitude)"
    coords::Tuple{Float64,Float64,Float64}
    "Contact/Cliente"
    client::String
    "Root path of the project"
    path::String
    "Work folders/directories"
    folders::Dict{Symbol,String}
    "Modules used in the project"
    modules::Vector{TDict}
    "Dicionário do toml"
    toml::TDict
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



function parseprojecttoml(toml, path)
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
    

    project = LabDaqProject(name, tag, descr, address, coords, client, path,
                        folders, modules, toml)
    
    
end



function generateproject(tomlfile, path=nothing)
    
    project = loadproject(tomlfile)

    # Agora baixar as coisas e gerar as pastas necessárias
    
    return project
    
end        

function loadproject(tomlfile, path=nothing)
    conf = LabDaqConf(tomlfile, path)
    
    toml = confdict(conf)
    root = rootpath(conf)
    
    # Agora vamos os arquivos 
    project = parseprojecttoml(toml, root)
    return project
    
end


project(c::LabDaqProject) = c
project(c::AbstractLabDaqProject) = c.project
projectname(c::AbstractLabDaqProject) = project(c).name

projecttag(c::AbstractLabDaqProject) = project(c).tag
projectpath(c::AbstractLabDaqProject) = c.path
projectroot(c::AbstractLabDaqProject) = project(c).path
projectfile(c::AbstractLabDaqProject) = project(c).fname
projecttoml(c::AbstractLabDaqProject) = project(c).toml
    
projectpath(c::AbstractLabDaqProject, p...) = projectpath(projectpath(c), p...)

function projectpath(c::AbstractLabDaqProject, folder::Symbol, p...;
                     file=true, build=false)

    root = projectpath(c)
    fld = projectfolder(c, folder)
    return projectpath(root, fld, p...; file=file, build=build)
end    

projectaddress(c::AbstractLabDaqProject) = project(c).address
projectcoords(c::AbstractLabDaqProject) = project(c).coords


projectfolder(c::AbstractLabDaqProject, folder::Symbol) = c.folders[folder]
projectdescr(c::AbstractLabDaqProject) = project(c).descr


function generateproject(project::AbstractLabDaqProject)

    path = projectpath(project)

    if !isdir(path)
        mkdir(path)
    end

end

workpath(c::AbstractLabDaqProject, p...; file=true, build=false) =
    projectpath(c, :work, p...; file=file, build=build)
outputpath(c::AbstractLabDaqProject, p...; file=true, build=false) =
    projectpath(c, :output, p...; file=file, build=build)
reportpath(c::AbstractLabDaqProject, p...; file=true, build=false) =
    projectpath(c, :report, p...; file=file, build=build)

scriptspath(c::AbstractLabDaqProject, p...; file=true, build=false) =
    projectpath(c, :scripts, p...; file=file, build=build)
processpath(c::AbstractLabDaqProject, p...; file=true, build=false) =
    projectpath(c, :process, p...; file=file, build=build)

measpath(c::AbstractLabDaqProject, p...; file=true, build=false) =
    projectpath(c, :measdata, p...; file=file, build=build)


    
