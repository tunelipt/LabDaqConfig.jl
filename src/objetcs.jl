# Here we provide the basic framework to build obects from TOML configurations

const _labdaqtypes_ = Dict{String,Function}()

function labdaqcreate(toml, field="type")
    # This is the basic interface!
    k = keys(toml)

    if field ∉ k
        error("The configuration file should have field $field!")
    end
    
    t = toml[field]
    if t ∉ keys(_labdaqtypes_)
        error("Type $t is not registered in `LabDaqConf`")
    end

    return _labdaqtypes_[t](toml)
end

function labdaqregister(ftype::String, fun::Function)
    _labdaqtypes_[ftype] = fun
end

