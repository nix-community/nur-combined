{
  lib,
  pkgs,
  inputs,
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
      android-tools
      wireshark
      gimp
      inkscape
      tor-browser
      digikam
      virt-manager
      libreoffice
      darktable
      biz-ud-gothic
      eownerdead.morisawa-biz-ud-mincho
      libimobiledevice
      openrgb-with-all-plugins
      feather
      xmrig-mo
      gthumb
    ];
  };

  eownerdead = {
    imperm.enable = true;
    emacs.enable = true;
    gnome.enable = true;
    mozc.enable = true;
    agents = {
      mcp.enable = true;
      opencode.enable = true;
    };
  };

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
