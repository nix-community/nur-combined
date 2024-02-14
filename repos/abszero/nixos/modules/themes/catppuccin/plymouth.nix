{ config, pkgs, ... }:

let inherit (config.lib.catppuccin) getVariant; in

{
  imports = [ ./_options.nix ];

  boot.plymouth = {
    enable = true;
    themePackages = with pkgs; [
      (catppuccin-plymouth.override {
        variant = getVariant;
      })
    ];
    theme = "catppuccin-${getVariant}";
  };
}
