{ lib, pkgs, inputs, ... }: {
  imports = [
    ../../hm

    ../noobuser/cli.nix
    ../noobuser/git.nix
    ../noobuser/gpg.nix
    ../noobuser/pass.nix
    ../noobuser/firefox.nix

    ../noobuser/dev/nix.nix
  ];

  home = {
    username = "eownerdead";
    homeDirectory = "/home/eownerdead";
    stateVersion = "24.05";

    packages = with pkgs; [ dconf jetbrains-mono wayfire ];
  };

  programs = {
    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      # https://github.com/NixOS/nixpkgs/issues/158449
      extensions = [{
        id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; # uBlock Origin
      }];
    };
    home-manager.enable = true;
  };
}

