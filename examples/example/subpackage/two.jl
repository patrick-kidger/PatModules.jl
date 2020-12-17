using PatModules

@auxmodule two ("utils",) begin
    function say_bye()
        utils.say("bye")
    end
end