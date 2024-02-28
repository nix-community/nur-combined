# nix-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**


## Installation

First include NUR in your `packageOverrides`:

To make NUR accessible for your login user, add the following to `~/.config/nixpkgs/config.nix`:

```nix
{
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
```


For NixOS add the following to your `/etc/nixos/configuration.nix`
Notice: If you want to use NUR in nix-env, home-manager or in nix-shell you also need NUR in `~/.config/nixpkgs/config.nix`
as shown above!

```nix
{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}

## How to use

Then packages can be used or installed from the NUR namespace.

```console
$ nix-shell -p nur.repos.nousefreak.projecthelper
nix-shell> projecthelper -h
...
```

or

```console
$ nix-env -f '<nixpkgs>' -iA nur.repos.nousefreak.projecthelper
```

or

```console
# configuration.nix
environment.systemPackages = with pkgs; [
  nur.repos.nousefreak.projecthelper
];
```

