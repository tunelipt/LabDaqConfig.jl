# Arquivos de configuração

"""
`AbstractLabDaqConf`

An abstract type that uses TOML 
"""
abstract type AbstractLabDaqConf end

const TDict = Dict{String,Any}
const Folders = Dict{Symbol,String}

const registered_modules = [
    :blpitot,  # Camada limite com Pitot Prandtl
    :blhw,     # Camada limite com fio quente
    :pressure] 

const default_folders = Dict(:output=>"output", :work=>"work",
                             :measdata=>"medidas", :scripts=>"scripts",
                             :process=>"process", :report=>"relatorio",
                             :modules=>"modules")

mutable struct LabDaqConf <: AbstractLabDaqConf
    toml::TDict
    path::String
end

function Base.show(io::IO, p::LabDaqConf)
    println(io, "root: $(rootpath(p))")
    println(io, "  with fields:")
    for k in keys(p)
        println("    $k")
    end
            
end


    """
`LabDaqConf(file, path=nothing)`

Creates a `LabDaqConf` from a file.

Every `LabDaqConf` has a root path that is used to build path names. If not provided,
it will try to use the directory 

"""
function LabDaqConf(file::AbstractString, path=nothing)

    # Let's read and parse the file
    str = read(file, String)
    toml = TOML.parse(str)
    # Let's get the root path.
    if isnothing(path)
        # The path will be hardcoded to directory name where the file is located
        root = dirname(abspath(file))
    else
        if path == ""
            # Current path
            root = pwd()
        else
            root = expanduser(path)
        end
    end
    
    new(toml, root)

end


Base.getindex(c::AbstractLabDaqConf, index) = c.toml[index]
Base.setindex!(c::AbstractLabDaqConf, val, index) = c.toml[index] = val
Base.keys(c::AbstractLabDaqConf) = keys(c.toml)
Base.values(c::AbstractLabDaqConf) = values(c.toml)
# Maybe I should implement the itaration stuff? Probably useless


"""
`rootpath(c::AbstractLabDaqConf)`

Returns a root path from a configuration
"""
rootpath(c::AbstractLabDaqConf) = c.path

confdict(c::AbstractLabDaqConf) = c.toml

LabDaqConf(c::AbstractLabDaqConf) = LabDaqConf(confdict(c), rootpath(c))
LabDaqConf(c::AbstractLabDaqConf, index) = LabDaqConf(confdict(c)[index],
                                                      rootpath(c))
LabDaqConf(c::AbstractLabDaqConf, index, path) =
    LabDaqConf(confdict(c)[index],
               joinpath(rootpath(c), expanduser(path)))
                                                      

               
