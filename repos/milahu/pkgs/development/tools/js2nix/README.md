# js2nix [![Build and test js2nix](https://github.com/canva-public/js2nix/actions/workflows/main.yml/badge.svg)](https://github.com/canva-public/js2nix/actions/workflows/main.yml)

A tool that makes use of the [Nix] package manager to install [Node.js] dependencies declared in `package.json` and `yarn.lock` files. It is an experimental project to discover opportunities to use Nix for Node.js dependencies. Read more about the background problems [here](./docs/background.md).

### Goals of the project

- Provide incremental `node_modules` installations (don't build what have already been built) by turning every individual npm package into a self-containing Nix derivation
- Handle dependency cycles
- Allow overriding a package
- Allow package life-cycle scripts and their overrides
- Make the dependency graph explicit (expressed in Nix) and well-controlled with all the above
- Remove the need to be check generated files into a code-base, provides IFD if required
- Make the generation of the Nix expression pure, so no assumptions are made around missing SHAs, local packages locations, etc

### Details

It is implemented as a CLI tool written in JavaScript and as a Nix library that picks up that tool and executes it internally to generate a Nix expression out of the given tuple of `package.json` & `yarn.lock` files in a pure manner as a separate Nix derivation, that then can be imported into the Nix runtime and the generated Nix derivations will be built via the provided Nix library to install Node.js dependencies. 

Then the artifact can be symlinked to some local location as a `node_modules` folder or can be placed, or picked up by Nix as a part of `NODE_PATH` to make it available for the Node.js resolution mechanism. Also, every derivation that represents an npm package is a first-class citizen in Nix and can be used independently, which is a convenient way to provide Node.js based CLIs in Nix. That is, if the npm package exposes a binary, it will be picked up by Nix and being made available in `PATH`, with no additional effort.

### A quick example

Let's create a file `package.nix` of a Nix expression with the following content:

```nix
with import <nixpkgs> { };

let
  js2nix = callPackage (builtins.fetchGit {
    url = "ssh://git@github.com/canva-public/js2nix.git";
    ref = "main";
  }) { };
  env = js2nix {
    package-json = ./package.json;
    yarn-lock = ./yarn.lock;
  };
in env.nodeModules
```
And then a `node_modules` folder can be created via:

```
 nix-build --max-jobs auto --out-link ./node_modules ./package.nix
```

The `nodeModules` is a Nix derivation that contains a compatible with [Node.js module resolution algorithm](https://nodejs.org/api/modules.html#all-together) layout. Note that the layout of the resulting `node_modules` is similar to what [`PNPM`](https://pnpm.io) package manager is providing, that is not a [flat](https://npm.github.io/how-npm-works-docs/npm3/how-npm3-works.html) layout but rather the canonical layout with symlinked (from the Nix store) npm packages into it.

To find out more about the project, its background, implementation details, how to use it please go to the [documentation space](./docs/README.md).

[nix]: https://nixos.org
[node.js]: https://nodejs.org
