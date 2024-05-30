# 📦 nur-packages.pkgs

Custom packages containing packaged artifacts from other repositories.

## 🔍 meta.{attributes}

Customizations to custom packages might be needed for CI caches. Some attributes
might be needed most:

- `meta.broken`: broken packages
- `meta.license.free`: unfree packages
- `preferLocalBuild`: local builds

## 🏁 result.{#using}

Direct paths to the built source can be used in place of `zimpkgs` for faster
development:

```diff
- zimpkgs = import (builtins.fetchTarball "https://github.com/zimeg/nur-packages/archive/main.tar.gz") {};
- zimpkgs.zsh-wd
+ zsh-wd = /path/to/nur-packages/result;
```

Results can be built from changes to the source using a build command:

```sh
$ nix build .#zsh-wd
$ ls -R ./result
```
