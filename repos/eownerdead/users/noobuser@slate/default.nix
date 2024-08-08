{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence

    ../../hm

    ../noobuser/cli.nix
    ../noobuser/git.nix
    ../noobuser/gpg.nix
    ../noobuser/pass.nix
    ../noobuser/firefox.nix
    ../noobuser/gnome.nix
    ../noobuser/virt-manager.nix

    ../noobuser/dev/nix.nix
    ../noobuser/dev/py.nix
    ../noobuser/dev/web.nix
  ];

  home = {
    username = "eownerdead";
    homeDirectory = "/home/eownerdead";
    stateVersion = "24.05";
    packages = with pkgs; [
      jetbrains-mono
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      my.morisawa-biz-ud-gothic
      my.morisawa-biz-ud-mincho
      gnome.dconf-editor
      tor-browser
      libreoffice
      pandoc
      element-desktop-wayland
      fractal
      rnote
      xournalpp
      drawing
      newsflash
      d-spy
      dialect
      gnome.cheese
      wgcf
      wireshark
      cloudflared
      thunderbird
      rclone
      vlc
      virt-manager
      gimp
      krita
      inkscape
      my.wpsoffice-mui
      gnome-decoder
    ];
    persistence."/nix/persist/home/eownerdead" = {
      allowOther = true;
      directories = [
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
        "src"
        ".gnupg"
        ".ssh"
        ".local/share/direnv"
        ".cache"
        ".mozilla/firefox"
        ".thunderbird"
      ];
    };
  };

  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    configFile."mozc/config1.db".source = ../noobuser/config1.db;
  };

  eownerdead.emacs.enable = true;

  fonts.fontconfig.enable = true;

  programs = {
    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      # https://github.com/NixOS/nixpkgs/issues/158449
      extensions = [
        {
          id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; # uBlock Origin
        }
      ];
    };
    home-manager.enable = true;
  };
}
