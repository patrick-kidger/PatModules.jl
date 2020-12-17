using PatModules

@mainmodule example ("subpackage",) begin
    function greetings()
        subpackage.say_hi()
        subpackage.say_bye()
    end
end

