using PatModules
@mainmodule example ("subpackage", "utils") begin

    function greetings()
        utils.do_nothing()
        subpackage.say_hi()
        # Can descend into subsubpackages
        subpackage.two.say_bye()
    end
end