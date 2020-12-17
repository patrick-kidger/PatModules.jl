# PatModules.jl

Writing modular, reusable code in Julia can be quite hard. To get access to any particular file you need to `include(...)` it -- but each file must only be `include`-d once. (Otherwise the definitions are evaluated multiple times, possible in different contexts, bad things start happening.) And if a file can only be `include`-d once, then it's hard to re-use it!

Previous "best practice" has been to do all `include`s in some "master" global file, and have everything else implicitly assume that whatever it needs `include`-ing will in fact have been included for it. What a hard-to-maintain mess that is! You need to get the `include`s in the global file in the right order, and have very little way of tracking what actually depends on what. Not a sensible way to scale to projects larger than just a few files.

_PatModules.jl_ is the solution.

## Example
TODO

## How does it work?
TODO