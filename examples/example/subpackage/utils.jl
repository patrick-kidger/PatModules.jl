using PatModules

@auxmodule utils () begin
    function say(msg)
        println(msg)
    end
end