{ inputs, ... }:
{
  imports = [
    inputs.nixcfg.modules.home.defaults
    inputs.nixcfg.modules.home.users.toyvo
    inputs.nixcfg.modules.home.programs.bat
    inputs.nixcfg.modules.home.programs.eza
    inputs.nixcfg.modules.home.programs.git
    inputs.nixcfg.modules.home.programs.ssh
    inputs.nixcfg.modules.home.programs.volta
    inputs.nixcfg.modules.home.programs.zellij
    inputs.nixcfg.modules.home.programs.editors.helix
    inputs.nixcfg.modules.home.programs.editors.ideavim
    inputs.nixcfg.modules.home.programs.editors.neovim
    inputs.nixcfg.modules.home.programs.editors.zed
    inputs.nixcfg.modules.home.programs.shells.bash
    inputs.nixcfg.modules.home.programs.shells.fish
    inputs.nixcfg.modules.home.programs.shells.ion
    inputs.nixcfg.modules.home.programs.shells.nushell
    inputs.nixcfg.modules.home.programs.shells.powershell
    inputs.nixcfg.modules.home.programs.shells.zsh
    inputs.nixcfg.modules.home.programs.terminals.hyper
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
