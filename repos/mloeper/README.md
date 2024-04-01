# NUR repository for mloeper

## Cachix

### How to get binary builds for this NUR repository?

We currently only build for the `x86_64-linux` platform.   
To speed up your builds on that platform, add the following config: `config.mloeper.cachix.enable = true;`.

## FAQ

Some notes for the packages maintainer:

### Howto maintain packages

How to develop the `git-credential-manager` package?

`nix develop .#packages.x86_64-linux.git-credential-manager`

Use `dontUnpack=1 genericBuild` to do the build manually.


### Where is the dotnet module defined? 

https://github.com/NixOS/nixpkgs/tree/master/pkgs/build-support/dotnet/build-dotnet-module


### Where can I find nixpkgs coding conventions?

https://ryantm.github.io/nixpkgs/contributing/coding-conventions/


### The pain with submodules

I want to cache some nix packages that I authored in other GitHub repositories.
Currently, there is a lack of consent how to do this properly on NUR.

There are [git submodule and fetchTree](https://discourse.nixos.org/t/nixos-build-flake-cant-read-a-file-in-a-submodule/21932) approaches, but neither looks straightforward to me.
To be pragmatic here, I just use a git subtree to include my upstream packages as they are relatively small in size.
The moment a proper solution emerges, I will replace this workaround. If you know a better solution, feel free to post me on [LinkedIn](https://www.linkedin.com/in/martinloeper).

`git subtree add --prefix pkgs/s3-browser-cli https://github.com/nesto-software/s3-browser-cli.git main --squash`

To update the subtree, run: `git subtree pull --prefix pkgs/s3-browser-cli https://github.com/nesto-software/s3-browser-cli.git main --squash`