using PatModules
include("utils.jl")

@once module one
    import ..utils

    function say_hi()
        utils.say("hi")
    end
end