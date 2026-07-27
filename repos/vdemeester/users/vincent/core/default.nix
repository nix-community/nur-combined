{ lib, pkgs, nixosConfig, ... }:

let
  inherit (lib) versionOlder;
in
{
  imports = [
    ./bash.nix
    ./direnv.nix
    ./fzf.nix
    ./git.nix
    ./gpg.nix
    ./htop.nix
    ./ssh.nix
    ./tmux.nix
    ./xdg.nix
    ./zsh.nix
  ];

  home = {
    stateVersion = "22.05";
    packages = with pkgs; [
      enchive
      entr
      # exa # TODO: switch to eza in 2024
      fd
      htop
      mosh
      ncurses
      pciutils
      ripgrep
      ugrep
      scripts
      tree
      broot
      lf
      usbutils
    ];
  };

  # manpages are broken on 21.05 and home-manager (for some reason..)
  # (versionOlder nixosConfig.system.nixos.release "21.11");
  manual.manpages.enable = true;

  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';
}
