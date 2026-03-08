{ inputs, ... }:
{
  imports = [
    ../../modules/home/defaults.nix
    ../../modules/home/users/toyvo.nix
    ../../modules/home/programs/bat.nix
    ../../modules/home/programs/eza.nix
    ../../modules/home/programs/git.nix
    ../../modules/home/programs/gtk.nix
    ../../modules/home/programs/kde.nix
    ../../modules/home/programs/ssh.nix
    ../../modules/home/programs/volta.nix
    ../../modules/home/programs/zellij.nix
    ../../modules/home/programs/editors/helix.nix
    ../../modules/home/programs/editors/ideavim.nix
    ../../modules/home/programs/editors/neovim.nix
    ../../modules/home/programs/editors/zed.nix
    ../../modules/home/programs/shells/bash.nix
    ../../modules/home/programs/shells/fish.nix
    ../../modules/home/programs/shells/ion.nix
    ../../modules/home/programs/shells/nushell.nix
    ../../modules/home/programs/shells/powershell.nix
    ../../modules/home/programs/shells/zsh.nix
    ../../modules/home/programs/terminals/alacritty.nix
    ../../modules/home/programs/terminals/ghostty.nix
    ../../modules/home/programs/terminals/hyper.nix
    ../../modules/home/programs/terminals/kitty.nix
    ../../modules/home/programs/terminals/rio.nix
    ../../modules/home/programs/terminals/wezterm.nix
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
}
