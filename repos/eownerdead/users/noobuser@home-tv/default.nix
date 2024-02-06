{ lib, pkgs, ... }: {
  imports = [
    ../noobuser/cli.nix
    ../noobuser/git.nix
    ../noobuser/gpg.nix
    ../noobuser/fish.nix
    ../noobuser/kodi.nix

    ../noobuser/dev/nix.nix
  ];

  home = {
    username = "noobuser";
    homeDirectory = "/home/noobuser";
    stateVersion = "21.11";
  };
}
