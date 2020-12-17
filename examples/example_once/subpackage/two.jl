using PatModules
include("utils.jl")
@once module two
    import ..utils

    function say_bye()
        utils.say("bye")
    end
end