module PatModules

export @once, @mainmodule, @auxmodule

# Adapted from https://github.com/JuliaLang/julia/issues/29966
macro once(m)
    @assert m.head === :module
    name = m.args[2]
    gvname = Symbol("#@once#gv#for#$name")
    quote
        if !isdefined($__module__, $(QuoteNode(gvname)))
            global $(esc(gvname)) = 1
            Core.eval($__module__, $(QuoteNode(m)))
        end
        nothing
    end
end


function _include(modul, to_import)
    modul
    for importname ∈ to_import
        if isdir(importname)
            _, filename = splitdir(importname)
            Base.include(modul, joinpath(importname, filename) * ".jl")
        else
            Base.include(modul, importname * ".jl")
        end
    end
end


function _module(name::Symbol, to_import_expr::Expr, block::Expr, __module__, __source__; is_aux::Bool)
    to_import::Tuple{Vararg{String}} = map(String, eval(to_import_expr))
    for importname ∈ to_import
        @assert !occursin("/", importname)
        @assert !occursin("\\", importname)
        @assert !occursin(".", importname)
    end
    path = String(__source__.file)
    path = abspath(path)
    path = realpath(path)
    path, _ = splitdir(path)
    to_include = map((importname)->joinpath(path, importname), to_import)

    m = quote
        if $is_aux
            $_include($__module__, $to_include)
        end
        @once module $name
            if !$is_aux
                $_include($name, $to_include)
            end
            for importname ∈ $to_import
                importname_symbol = Symbol(importname)
                if $is_aux
                    Core.eval($name, :(import .. $importname_symbol))
                else
                    Core.eval($name, :(import .$importname_symbol))
                end
            end
            $block
        end
    end
    quote
        using PatModules
        Core.eval($__module__, $(QuoteNode(m)))
    end
end


macro mainmodule(name::Symbol, to_import_expr::Expr, block::Expr)
    _module(name, to_import_expr, block, __module__, __source__; is_aux=false)
end


macro auxmodule(name::Symbol, to_import_expr::Expr, block::Expr)
    _module(name, to_import_expr, block, __module__, __source__; is_aux=true)
end

end