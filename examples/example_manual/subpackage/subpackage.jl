using PatModules

@once module subpackage
    include("one.jl")
    include("two.jl")

    import .one: say_hi
    import .two: say_bye
end