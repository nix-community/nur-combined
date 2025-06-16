# TonyWu20 [NUR](https://github.com/nix-community/NUR) repository

## Basic usage

- To make NUR accessible for your login user, add the following to `~/.config/nixpkgs/config.nix`:

```nix
{
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
```

- List the packages

```console
$ nix-env -f "<nixpkgs>" -qaP -A nur.repos.tonywu20
```

- Install a package

```console
$ nix-env -iA -f "<nixpkgs>" nur.repos.tonywu20.intel-oneapi-essentials
```

## Advanced usage (mostly for admins)

- Local build of a package:

```
nix-build --arg pkgs 'import <nixpkgs> {}' -A hello
```

- Force an update of the repository

```
curl -XPOST https://nur-update.nix-community.org/update?repo=tonywu20
```
