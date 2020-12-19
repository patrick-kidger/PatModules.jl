using PatModules
@auxmodule! one ("utils",) begin
    export say_hi

    function say_hi()
        say("hi")
    end
end