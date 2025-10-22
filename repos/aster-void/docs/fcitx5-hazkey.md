# Fcitx5 Hazkey (v0.0.9)

The main repo is at <https://github.com/7ka-Hiira/fcitx5-hazkey>.

## Installation

There are two parts to be set up for fcitx5-hazkey to work:

- a. `/usr/share/hazkey` that contains zenzai and dictionary data
- b. fcitx5 addon

### a. `/usr/share/hazkey`

this flake provides an automatic setup.

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

the module above does NOT set this up, therefore you need to manage it yourself.

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
