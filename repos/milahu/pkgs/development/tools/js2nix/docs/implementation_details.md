## Implementation details

js2nix is implemented as a CLI tool written in JavaScript and a Nix library that picks up that tool and executes it internally. This then generates a Nix expression out of the given tuple of `package.json` and `yarn.lock` files in a pure manner as a separate derivation, that then can be imported into the Nix runtime and the generated Nix derivations are built via the provided Nix library to install Node.js dependencies. The artifact can then be symlinked to a local location as a `node_modules` folder or can be placed or picked up by Nix as a part of `NODE_PATH` to make it available for the Node.js resolution mechanism. 

Every derivation that represents an npm package is a first-class citizen in Nix and can be used independently, which is a convenient way to provide Node.js based CLIs in Nix. That is, if the npm package exposes a binary, it will be picked up by Nix and made available in `PATH` with no additional effort.

### The `node_modules` folder layout

The classic approach to get Node.js dependencies ready to use is to have nested `node_modules` folders for every package that has dependencies. While this approach is correct, it has a major downside: some dependencies will be duplicated, which leads to unnecessary redundancy.

To address this, yarn and npm use a flat module structure where almost all the dependencies are hoisted to the top-level `node_modules` folder, except those dependencies that have a clash on the top level. This approach makes sense when all the dependencies must be placed in a `node_modules` folder as real paths in order to reduce file duplication, as described earlier.

For more information, see [how npm works](https://npm.github.io/how-npm-works-docs/npm3/how-npm3-works.html).

However, none of these approaches work well for the goals of this project. The nested structure won't allow having full control over every individual package, because all the dependencies are placed in a nested folder and are part of a single artefact. The flat module approach doesn't work well either, because every package in the flat structure is a context-dependent package that cannot be re-used outside of that particular installation, breaking granularity.

Instead, js2nix installs all the dependencies into a `node_modules` folder where every single package is symlinked from the Nix store, replicating [what pnpm does](https://www.kochan.io/nodejs/why-should-we-use-pnpm.html). For example:

```
λ tree ./node_modules
./node_modules
├── @webassemblyjs
│   └── ast -> /nix/store/<...>-babel-core-1.9.1/pkgs/babel---core@1.9.1/node_modules/@webassemblyjs/ast
└── semver -> /nix/store/<...>-semver-7.3.5/pkgs/semver@7.3.5/node_modules/semver
```

And if we check the `semver` package further:

```
λ tree /nix/store/<...>-semver-7.3.5/pkgs/semver@7.3.5/node_modules/
/nix/store/<...>-semver-7.3.5/pkgs/semver@7.3.5/node_modules/
├── lru-cache -> /nix/store/<...>-lru-cache-6.0.0/pkgs/lru-cache@6.0.0/node_modules/lru-cache
└── semver
    ...
    ├── README.md
    ├── package.json
    ...
```

> _<sup>Nix hashes have been replaced with `<...>` because of readability reasons</sup>_

As you can see, every package is placed into the `/nix/store/*/pkgs/<package>@<version>/node_modules/*` folder. This is to allow packages to require themselves, as some of them do, as well as place more than one package into a single derivation to host dependency cycles (see below), since Nix doesn't support a dependency tree that is not a DAG.

### Dependency cycles

You can publish npm packages that have dependency cycles to public registries. For example, `A` depends on `B` that depends on `A`. Since Nix represents dependencies as a directed acyclic graph, it's not possible to express such cases in Nix. However, it's possible to host such dependency cycles within a single Nix derivation so cycles will be scoped by a single module and won't leak outside. 

For a more complex example, assume the following dependency graph:

```
A → B → C → D → ╮
        ╰ ← ← ← E ← ╮
                ╰ → F
```

The `C` package transitively depends on itself. 

Let's see how this can be represented in a form that remains operational and doesn't have cycles between Nix derivation.

We have to have self-containing packages to address granularity and provide re-usability, so we can't pop up all the packages to the top-level. However, we can place cycled packages at the level where a cycle was first introduced and scope such cycle within a single Nix derivation. By doing that, we sacrifice context independence of all the dependencies of `C`, but this happens for the smallest context possible.

So resolved dependency graph will look like this:

```
A → B → C → C+D → ╮
        ╰ ← ←  ← C+E ← ╮
                  ╰ → C+F
```

Where `C+D`, for example, means that the `D` package is physically hosted within the Nix derivation of the `C` package. That is, the `D` package is going to be copied into the `C` package folder rather than symlinked from the Nix store. Note that the `F` package is being hosted by `C` but not `E`, because `E` is being hosted by `C` already.

And the resulting files structure of the `C-x.x.x` derivation resembles the following:

```
λ tree -L 3 /nix/store/<...>-C-x.x.x/pkgs/
/nix/store/<...>-C-x.x.x/pkgs/
├── C@x.x.x
|   └── node_modules
|       ├── C
|       └── D -> ../../D@x.x.x/node_modules/D
├── D@x.x.x
|   └── node_modules
|       ├── D
|       └── E -> ../../E@x.x.x/node_modules/E
├── E@x.x.x
|   └── node_modules
|       ├── E
|       ├── F -> ../../F@x.x.x/node_modules/F
|       └── C -> ../../C@x.x.x/node_modules/C
└── F@x.x.x
    └── node_modules
        ├── F
        └── E -> ../../E@x.x.x/node_modules/E
```

So, every package in this set can access only its direct dependencies but not the others.

> Note: this is a particularly rare case but still needs to be considered.

### js2nix's runtime dependency on `node-gyp`

Packages that implement native extensions (for example, those that have `binding.gyp` files) must be built via `node-gyp`. This is an npm package that must be built in Nix first and then provided as native build inputs to the standard build process. To make this possible, js2nix bootstraps itself with no dependency on `node-gyp` to instantiate a minimal viable tool to be able to create the `node-gyp` Nix package, then js2nix instantiates itself with this pre-built `node-gyp` as it's native build input dependency.

This `node-gyp` package is available as:

```nix
js2nix.node-gyp
```

You can instantiate js2nix with the external `node-gyp` Nix package:

```nix
with import <nixpkgs> { };

let
  node-gyp = callPackage ./from/your/source.nix { };
  js2nix = callPackage (builtins.fetchGit {
    url = "ssh://git@github.com/Canva/js2nix.git";
    ref = "main";
  }) { inherit node-gyp; };
in js2nix
```

### Caveats

A full installation from scratch using Nix can take more time than one of the Node.js ecosystem's package managers like yarn or npm. This is because these tools are written for Node.js, which executes concurrent jobs within a single thread using an [event-loop](https://nodejs.dev/learn/the-nodejs-event-loop), so no context switching happens. This is a different approach to the traditional operating system threads used by Nix. You can still improve the speed using the [`--max-jobs`](https://nixos.org/manual/nix/stable/#opt-max-jobs) option or more [advanced techniques](https://nixos.org/manual/nix/unstable/advanced-topics/cores-vs-jobs.html).

This is the expected behaviour for Nix. A [substituters](https://nixos.org/manual/nix/stable/#conf-substituters) option (also known as a binary cache) exists to address this particular issue. Since Nix is optimised to use binary caches and handle such cases in a reasonable time, it is assumed that all artefacts of `node_modules` will be cached. A slow package-building process is not an issue, because it should only happen once in most cases.

[yarn]: https://classic.yarnpkg.com
[npm]: https://npmjs.com
