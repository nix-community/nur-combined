# NUR repository for mloeper

Some notes for the packages maintainer:

## Howto maintain packages

How to develop the `git-credential-manager` package?

`nix develop .#packages.x86_64-linux.git-credential-manager`

Use `dontUnpack=1 genericBuild` to do the build manually.


## Where is the dotnet module defined? 

https://github.com/NixOS/nixpkgs/tree/master/pkgs/build-support/dotnet/build-dotnet-module


## Where can I find nixpkgs coding conventions?

https://ryantm.github.io/nixpkgs/contributing/coding-conventions/

