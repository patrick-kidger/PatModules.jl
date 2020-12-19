using PatModules
@auxmodule! two ("utils",) begin
    export say_bye

    function say_bye()
        say("bye")
    end
end