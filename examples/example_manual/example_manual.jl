using PatModules

@once module example_manual
    include("subpackage/subpackage.jl")
    import .subpackage

    function greetings()
        subpackage.say_hi()
        subpackage.say_bye()
    end
end

