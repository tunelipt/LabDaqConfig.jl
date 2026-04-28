
# Just building paths


"""
projectpath(p...; file=true, build=false)

Constrói um caminho como se fosse `joinpath` mas permite que as pastas
intermediárias sejam criadas.

## Argumentos
 * `p...`: Os diferentes elementos do caminho
 * `file=true`: o caminho é um arquivo ou uma pasta?
 * `build=false`: criar
"""
function projectpath(p...; file=true, build=false)
    root = p[begin]

    path = joinpath(root, p...)
    if !build
        return path
    end
    
    # Vamos criar as pastas
         
    N = length(p)

    nf = file ? 1 : 0
    

    dname = root
    for folder in p[begin:end-nf]
        dname = joinpath(dname, folder)
        if isfile(dname)
            error("Existe um arquivo com nome $dname. Não posso criar esta pasta!")
        elseif !isdir(dname)
            mkpath(dname)
        end
    end

    return path
    
end
    
