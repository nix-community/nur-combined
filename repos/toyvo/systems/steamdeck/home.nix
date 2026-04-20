{ pkgs, inputs, ... }:
{
  imports = [
    inputs.nixcfg.modules.home.default
    inputs.plasma-manager.homeModules.plasma-manager
    inputs.catppuccin.homeModules.catppuccin
    inputs.nh.homeManagerModules.default
    inputs.nix-index-database.homeModules.nix-index
    inputs.nur.modules.homeManager.default
    inputs.nvf.homeManagerModules.nvf
    inputs.sops-nix.homeManagerModules.sops
  ];
  nixpkgs = {
    overlays = [
      inputs.nixpkgs-esp-dev.overlays.default
      inputs.self.overlays.default
      inputs.nur.overlays.default
      inputs.rust-overlay.overlays.default
      # inputs.zed.overlays.default
    ];
    config = {
      allowUnfree = true;
      allowBroken = true;
    };
  };
  home = {
    username = "deck";
    homeDirectory = "/home/deck";
    packages = with pkgs; [
      r2modman
      (wrapOBS {
        plugins = with obs-studio-plugins; [
          obs-gstreamer
          obs-vkcapture
          obs-vaapi
        ];
      })
    ];
  };
  profiles = {
    chloe.enable = true;
    defaults.enable = true;
    gui.enable = true;
  };
}
