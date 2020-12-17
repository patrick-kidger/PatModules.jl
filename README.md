# PatModules.jl

Writing modular, reusable code in Julia is harder than in other languages. To get access to any particular file you need to `include(...)` it -- but each file can only be `include`-d once. (Otherwise the definitions are evaluated multiple times, possible in different contexts, bad things start happening.) And if a file can only be `include`-d once, then it's hard to re-use its code.

Previous "best practice" has been to do all `include`s in some "master" global file, and have everything else implicitly assume that whatever it needs `include`-ing will in fact have been included for it. What a hard-to-maintain mess that is! You may need to get the `include`s in the global file in the right order, and you have very little way of tracking what actually depends on what. Not a good way to scale to projects larger than just a few files.

**PatModules.jl is the solution.**

## Installation

```julia
] add https://github.com/patrick-kidger/PatModules.jl
```

## Example
Have a look at [the example](./examples/example) for a quick example. In particular, notice that:
- `subpackage/one.jl` and `subpackage/two.jl` _both explicitly_ depend on `subpackage/utils.jl`, without errors due to redefining a module.
- both `utils.jl` and `subpackage/utils.jl` create modules with the same name without them clashing.
- `example.jl` can include the whole subpackage with just "subpackage", and can descend into subsubpackages at will.
- Every file can be run stand-alone: no implicit assumptions about how the context in which the file will be `include`d.

## How does it work / how do I use it?
PatModules.jl introduces two new macros, `@mainmodule` and `@auxmodule`.

Every folder should have a file of the same name, e.g. `subpackage/subpackage.jl`, which is denoted a "main module". (Equivalent to `__init__.py` in Python.) Every other file in that folder is an "auxiliary module".

The syntax for both is
```julia
<@mainmodule|@auxmodule> <name> ("<import1>", "<import2>", ...) begin
    <module contents>
end
```
for example
```julia
@auxmodule my_amazing_module ("another_module",) begin
    function my_amazing_function()
        another_module.some_functionality()
        ...
    end
    ...
end
```

_Each file should have at its top level a single @mainmodule/@auxmodule with the same name as the file._ For example `subpackage/utils.jl` should have (and only have) `@auxmodule utils ...` at its top level. (This does unfortunately mean that the name of each main module has to be specified three times: in the folder name, file name, and module name.)

The next argument is a tuple of strings, specifying what you'd like to import. These can be from among the other auxiliary modules in the same folder, or the names of any subfolders (with associated main modules one level down) in the same folder. These files/modules (same thing under this model) will all be imported automatically. (For example see how [subpackage.jl](./examples/example/subpackage/subpackage.jl) gets access to `one` and `two`.)

If you want to access anything in a subsubfolder, subsubsubfolder, etc., then do so by importing the subfolder and then doing dotted look up. (For example see how [example.jl](./examples/example/example.jl) gets access to `subpackage.two`.) Do _not_ try to `include` the subsub-* directly: this kind of behaviour is dangerous, and will likely result in two mutually unintelligble copies of the same code being compiled. (Which recall was one of the things that PatModules.jl sought to fix in the first place.)

If you want to access some installed module (i.e. from outside your project) then `import`/`using` it in the usual way, within the confines of the `@auxmodule` or `@mainmodule`. (If it's outside that then the contents of your module can't see it, just like normal in Julia.)

## I want a lower-level interface.
PatModules.jl also makes available another macro, `@once`, which can be called on a module definition so that it is only created once, _within the same context_, i.e. the outer module in which it is called. (It won't save you from `include`-ing the module in multiple different places.) This is what `@mainmodule` and `@auxmodule` rely on to not have to worry about importing things multiple times. Have a look at [`example_once`](./examples/example_once) for how this is used; this example mirrors the main [`example](./examples/example), so you can see what `@mainmodule` and `@auxmodule` get converted into.

## Future work
There's a couple things that would still be nice to add here.
- Add an option to have the listed imports be made available with `using` rather than `import`, if desired.
- Add a way to access modules from enclosing non-global scopes. (Like doing `import ...mymodule`.)
