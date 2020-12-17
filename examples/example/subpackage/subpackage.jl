using PatModules

@mainmodule subpackage ("one", "two") begin
    say_hi = one.say_hi
    say_bye = two.say_bye
end