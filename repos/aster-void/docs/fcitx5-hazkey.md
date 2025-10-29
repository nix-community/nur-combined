# Fcitx5 Hazkey

The upstream project lives at <https://github.com/7ka-Hiira/fcitx5-hazkey>.

## Install v0.0.9 (latest release)

```nix
{inputs, ...}: {
    # NixOS module
    imports = [ inputs.nix-repository.nixosModules.hazkey ];
    programs.hazkey.enable = true;

    # at where you define your input method at (HM or NixOS)
    i18n.inputsMethod = {
        fcitx5.addons = [inputs.nix-repository.packages.${pkgs.system}.fcitx5-hazkey];
    }
}
```

## Install latest git (unreleased)

```nix
{inputs, ...}: {
    # NixOS module
    imports = [ inputs.nix-repository.nixosModules.hazkey-git ];
    programs.hazkey-git.enable = true;

    # at where you define your input method at (HM or NixOS)
    i18n.inputsMethod = {
        fcitx5.addons = [inputs.nix-repository.packages.${pkgs.system}.fcitx5-hazkey-git];
    }
}
```
