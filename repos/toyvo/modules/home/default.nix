{
  # Add your Home Manager modules here
  #
  # my-module = ./my-module;
  default =
    { lib, inputs, ... }:
    {
      imports = [
        ./catppuccin.nix
        ./programs/bat.nix
        ./programs/editors/helix.nix
        ./programs/editors/ideavim.nix
        ./programs/editors/opencode.nix
        ./programs/editors/zed.nix
        ./programs/eza.nix
        ./programs/git.nix
        ./programs/gtk.nix
        ./programs/jujutsu.nix
        ./programs/kde.nix
        ./programs/pi.nix
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
        ./session.nix
        ./shells.nix
        ./sops.nix
        ./users/chloe.nix
        ./users/toyvo.nix
      ];

      options.nixcfg.gui.enable = lib.mkEnableOption "GUI Applications";
    };
  alacritty = ./programs/terminals/alacritty.nix;
  bash = ./programs/shells/bash.nix;
  bat = ./programs/bat.nix;
  catppuccin = ./catppuccin.nix;
  chloe = ./users/chloe.nix;
  eza = ./programs/eza.nix;
  fish = ./programs/shells/fish.nix;
  ghostty = ./programs/terminals/ghostty.nix;
  git = ./programs/git.nix;
  gtk = ./programs/gtk.nix;
  helix = ./programs/editors/helix.nix;
  hyper = ./programs/terminals/hyper.nix;
  ideavim = ./programs/editors/ideavim.nix;
  ion = ./programs/shells/ion.nix;
  jujutsu = ./programs/jujutsu.nix;
  kde = ./programs/kde.nix;
  kitty = ./programs/terminals/kitty.nix;
  nushell = ./programs/shells/nushell.nix;
  opencode = ./programs/editors/opencode.nix;
  pi = ./programs/pi.nix;
  powershell = ./programs/shells/powershell.nix;
  rio = ./programs/terminals/rio.nix;
  session = ./session.nix;
  shells = ./shells.nix;
  sops = ./sops.nix;
  ssh = ./programs/ssh.nix;
  toyvo = ./users/toyvo.nix;
  volta = ./programs/volta.nix;
  wezterm = ./programs/terminals/wezterm.nix;
  zed = ./programs/editors/zed.nix;
  zsh = ./programs/shells/zsh.nix;
}
