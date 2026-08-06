{
  # Add your Home Manager modules here
  #
  # my-module = ./my-module;
  default =
    { lib, ... }:
    {
      imports = [
        ./session.nix
        ./shells.nix
        ./sops.nix
        ./programs/bat.nix
        ./programs/editors/helix.nix
        ./programs/editors/ideavim.nix
        ./programs/editors/opencode.nix
        ./programs/editors/zed.nix
        ./programs/eza.nix
        ./programs/git.nix
        ./programs/gtk.nix
        ./programs/kde.nix
        ./programs/shells/bash.nix
        ./programs/shells/fish.nix
        ./programs/shells/ion.nix
        ./programs/shells/nushell.nix
        ./programs/shells/powershell.nix
        ./programs/shells/zsh.nix
        ./programs/ssh.nix
        ./programs/terminals/alacritty.nix
        ./programs/terminals/ghostty.nix
        ./programs/terminals/hyper.nix
        ./programs/terminals/kitty.nix
        ./programs/terminals/rio.nix
        ./programs/terminals/wezterm.nix
        ./programs/volta.nix
        ./users/chloe.nix
        ./users/toyvo.nix
      ];

      options.nixcfg.gui.enable = lib.mkEnableOption "GUI Applications";
    };
  session = ./session.nix;
  shells = ./shells.nix;
  sops = ./sops.nix;
  bat = ./programs/bat.nix;
  helix = ./programs/editors/helix.nix;
  ideavim = ./programs/editors/ideavim.nix;
  opencode = ./programs/editors/opencode.nix;
  zed = ./programs/editors/zed.nix;
  eza = ./programs/eza.nix;
  git = ./programs/git.nix;
  gtk = ./programs/gtk.nix;
  kde = ./programs/kde.nix;
  bash = ./programs/shells/bash.nix;
  fish = ./programs/shells/fish.nix;
  ion = ./programs/shells/ion.nix;
  nushell = ./programs/shells/nushell.nix;
  powershell = ./programs/shells/powershell.nix;
  zsh = ./programs/shells/zsh.nix;
  ssh = ./programs/ssh.nix;
  alacritty = ./programs/terminals/alacritty.nix;
  ghostty = ./programs/terminals/ghostty.nix;
  hyper = ./programs/terminals/hyper.nix;
  kitty = ./programs/terminals/kitty.nix;
  rio = ./programs/terminals/rio.nix;
  wezterm = ./programs/terminals/wezterm.nix;
  volta = ./programs/volta.nix;
  chloe = ./users/chloe.nix;
  toyvo = ./users/toyvo.nix;
}
