using PatModules

@auxmodule one ("utils",) begin
    function say_hi()
        utils.say("hi")
    end
end