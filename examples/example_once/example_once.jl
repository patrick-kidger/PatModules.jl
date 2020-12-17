using PatModules
@once module example_once
    include("subpackage/subpackage.jl")
    include("utils.jl")
    import .subpackage
    import .utils

    function greetings()
        utils.do_nothing()
        subpackage.say_hi()
        # Can descend into subsubpackages
        subpackage.two.say_bye()
    end
end