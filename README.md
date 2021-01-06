Have a look at [FromFile.jl](https://github.com/Roger-luo/FromFile.jl) for a probably better way of doing this. :)

---

# PatModules.jl

Writing modular, reusable code in Julia is harder than in other languages. To get access to any particular file you need to `include(...)` it -- but each file can only be `include`-d once. (Otherwise the definitions are evaluated multiple times, possibly in different contexts, bad things start happening.) And if a file can only be `include`-d once, then it's hard to re-use its code.

Previous "best practice" has been to do all `include`s in some "master" global file, and have everything else implicitly assume that whatever it needs `include`-ing will in fact have been included for it. You may need to get the `include`s in the global file in the right order, and you have very little way of tracking what actually depends on what. That's hard to maintain, and not a good way to scale to projects larger than just a few files.

\>>> **PatModules.jl is the solution.** <<<

## Documentation

### Installation

```julia
] add PatModules
```

### Example
Have a look at [the example](./examples/example) for a quick example. In particular, notice that:
- `subpackage/one.jl` and `subpackage/two.jl` _both explicitly_ depend on `subpackage/utils.jl`, without errors due to redefining a module.
- both `utils.jl` and `subpackage/utils.jl` create modules with the same name without them clashing.
- `example.jl` can include the whole "subpackage" _folder_ just by specifying "subpackage", and can descend into subsubpackages at will.
- Every file can be run stand-alone: no implicit assumptions about the context in which the file will be `include`d.

### Remind me how `include`/`import`/`using` works in Julia?
Briefly: `include` just copy-pastes the contents of one _file_ into another _file_. (Note that this is generally considered a bad way to move code around, see [this](https://stackoverflow.com/questions/13570947/what-is-the-difference-between-import-and-include-choices-in-language-design) StackOverflow post.) Meanwhile, `import`/`using` get the objects defined in one _module_, and make them available in another _module_.

What this means for writing re-usable code: you're forced to use `include` just to make the contents of one file visible to another, and then _also_ use either `import`/`using` to access it in Julia afterwards. Besides a two-step process being a bit ugly, this has all the issues mentioned in the introduction.

### How does PatModules.jl work / how do I use it?
PatModules.jl introduces two new macros, `@mainmodule` and `@auxmodule`. **Between them, you should never have to write a single `include` again.**

Every folder must have a file of the same name, e.g. `subpackage/subpackage.jl`, which is denoted a "main module". (Equivalent to `__init__.py` in Python.) Every other file is an "auxiliary module".

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

_Each file should have at its top level a single `@mainmodule`/`@auxmodule` with the same name as the file._ For example `subpackage/utils.jl` should have (and only have) `@auxmodule utils ...` at its top level.

The next argument is a tuple of strings, specifying what you'd like to import. These can be from among the other auxiliary modules in the same folder, or the names of any subfolders (with associated main modules one level down) in the same folder. The contents of these files will be `include`d in the correct manner, and will also all be `import`ed automatically. For example see how [subpackage.jl](./examples/example/subpackage/subpackage.jl) gets access to `one` and `two`. (If you would prefer it is `using`-d automatically then use `@mainmodule!` and `@auxmodule!` instead, see [`example_use`](./examples/example_use).)

If you want to access something in a subsubfolder, subsubsubfolder, etc., then do so by importing the subfolder and then doing dotted look up. (For example see how [example.jl](./examples/example/example.jl) gets access to `subpackage.two`.) Do _not_ try to `include` the subsub-* directly: this kind of behaviour is dangerous, and will likely result in two mutually unintelligible copies of the same code being compiled. (Which recall was one of the things that PatModules.jl sought to fix in the first place.)

If you want to access some globally installed module (i.e. from outside your project) then do `import`/`using` in the usual way, _within_ the block of the `@auxmodule` or `@mainmodule`. (If it's outside that then the contents of your module can't see it, which is normal in Julia.)

If you want to access some nonlocal module, then also do that with `import`/`using`, like doing `import ...mypackage`. Note that in this case the `include` part is not guaranteed to happen automatically, but provided the relevant module is imported with PatModules.jl at the higher level, then this should still work.

## Advanced notes
### I want a lower-level interface.
PatModules.jl also makes available another macro, `@once`, which can be called on a module definition so that it is only created once, _within the same context_, i.e. the outer module in which it is called. (It won't save you from `include`-ing the module in multiple different places.) This is what `@mainmodule` and `@auxmodule` rely on to not have to worry about importing things multiple times. Have a look at [`example_once`](./examples/example_once) for how this is used; this example mirrors the main [`example`](./examples/example), so you can see what `@mainmodule` and `@auxmodule` get converted into.

### Why is it implemented this way?
There's many sensible alternative ways of creating these sorts of import systems. One way would be to emulate Python: store all the modules somewhere global (like `sys.modules` in Python) and then route all import calls there. Another way would be to build a tree of modules and then linearise it with a topological sort relative to some specified root / entry point.

The main advantage of the approach we use here is that after macro expansion the end result still looks like normal Julia, and doing so doesn't involve too much magic. (Which the metaprogramming involved in the other approaches probably would be.) This means that PatModules.jl should be able to be used (or introduced incrementally into a project) without too many surprises.

## Future work
There's a couple things that would still be nice to add here.
- Add an `as` option to rename what's imported.
- Add a way to have the `include` happen for modules from enclosing non-global scopes. (Doing `import ...mymodule` still works but doesn't give you the guarantee that it's already been included.)
