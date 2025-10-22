# Fcitx5 Hazkey

The main repo is at <https://github.com/7ka-Hiira/fcitx5-hazkey>.

## Installation

There are two parts to be set up for fcitx5-hazkey to work:

a. `/usr/share/hazkey`
b. fcitx5 addon

### a. `/usr/share/hazkey`

This module sets this up automatically.

```nix
# NixOS module
{
    # get this flake somehow (flake inputs, NUR, or `getFlake`)
    imports = [ this-flake.nixosModules.hazkey ];
    programs.hazkey.enable = true;

    # optional.
    # if you just copy-pasted default.nix (instead of installing as a flake), you need to provide fcitx5-hazkey separately, otherwise it won't evaluate.
    programs.hazkey.package = fcitx5-hazkey-0_0_9;
}
```

### b. fcitx5 addon

This module does NOT set this up.

```nix
# either NixOS module or Home-Manager module
{pkgs, ...}:
{
    i18n.inputsMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.addons = [
            this-flake.packages.${pkgs.system}.fcitx5-hazkey;
        ]
    }
}
```
