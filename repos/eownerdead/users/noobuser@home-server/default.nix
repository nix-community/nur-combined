{ lib, pkgs, ... }: {
  imports = [
    ../noobuser/cli.nix
    ../noobuser/git.nix
    ../noobuser/gpg.nix
    ../noobuser/fish.nix

    ../noobuser/dev/nix.nix
  ];

  programs.git.extraConfig.credential.helper = [ "cache" ];

  home = {
    username = "noobuser";
    homeDirectory = "/home/noobuser";
    stateVersion = "21.11";
  };
}
