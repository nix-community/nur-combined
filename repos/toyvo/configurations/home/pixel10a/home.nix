{ pkgs, inputs, ... }:
{
  imports = [
    inputs.nixcfg.modules.home.default
    inputs.catppuccin.homeModules.catppuccin
    inputs.nix-index-database.homeModules.nix-index
    inputs.nur.modules.homeManager.default
    inputs.nvf.homeManagerModules.nvf
    inputs.sops-nix.homeManagerModules.sops
  ];
  nixpkgs = {
    overlays = [
      inputs.self.overlays.default
      inputs.nur.overlays.default
      inputs.rust-overlay.overlays.default
    ];
    config = {
      allowUnfree = true;
      allowBroken = true;
    };
  };
  home = {
    username = "droid";
    homeDirectory = "/home/droid";
  };
  programs.nix-index-database.comma.enable = true;
  nixcfg = {
    shells.enable = true;
    session.enable = true;
    sops-home.enable = true;
    users.toyvo.enable = true;
  };
}
