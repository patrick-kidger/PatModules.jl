using PatModules
@once module utils
    # Import external modules here
    # (not that Base is ever external, this is
    # just for illustration)
    import Base

    function say(msg)
        Base.println(msg)
    end
end