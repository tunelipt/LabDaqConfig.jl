module LabDaqConfig




export AbstractLabDaqConf, LabDaqConf, AbstractLabDaqProject, LabDaqProject
export projectpath, rootpath, confdict, projecttag, projectname
export projectaddress, projectcoords, projectdescr
export projectclient, projectfile
export projecttoml, generateproject, loadproject, projectfolder
export workpath, outputpath, reportpath, scriptspath, processpath, measpath
export labdaqcreate, labdaqregister

import TOML

include("path.jl")
include("config.jl")
include("project.jl")
include("module.jl")
include("tomlconfig.jl")
end
