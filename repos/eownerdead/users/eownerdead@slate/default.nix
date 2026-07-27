{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    ../../hm
  ];

  home = {
    username = "eownerdead";
    homeDirectory = "/home/eownerdead";
    stateVersion = "26.05";
    packages = with pkgs; [
      biz-ud-gothic
      eownerdead.morisawa-biz-ud-mincho
      tor-browser
      libreoffice
      pandoc
      element-desktop
      fractal
      rnote
      drawing
      newsflash
      cheese
      wgcf
      wireshark
      cloudflared
      thunderbird
      rclone
      virt-manager
      gimp
      krita
      inkscape
      eownerdead.wpsoffice-mui
    ];
    persistence."/nix/persist" = {
      directories = [
        ".local/share/epiphany"
        ".local/share/org.gnome.TextEditor"
        ".config/chromium"
        ".config/Element"
      ];
    };
  };

  eownerdead = {
    imperm.enable = true;
    emacs.enable = true;
    gnome.enable = true;
    mozc.enable = true;
    ghostty.enable = true;
  };

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
