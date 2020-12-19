using PatModules
@mainmodule! example_use ("subpackage", "utils") begin
    export greetings

    function greetings()
        do_nothing()
        say_hi()
        say_bye()
    end
end