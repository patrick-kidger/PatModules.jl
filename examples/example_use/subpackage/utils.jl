using PatModules
@auxmodule! utils () begin
    # Import external modules here
    # (not that Base is ever external, this is
    # just for illustration)
    import Base

    export say

    function say(msg)
        Base.println(msg)
    end
end