{ pkgs, lib, ...}:

with lib;

let

  cfg = config.kampka.profiles.common;

in {

    environment.systemPackages = with pkgs; [
      bash

      bat
      less
      most

      neovim
      ripgrep

      coreutils
      utillinux

      curl
      inetutils

      gzip
      bzip2
      xz
    ];

    environment.variables = {
      EDITOR = "nvim";
      PAGER = "most";
    };

    environment.shellAliases = {
      vi = "nvim";
      vim = "nvim";
      cat = "bat -p --pager=never";
    };


    i18n = {
      defaultLocale = mkDefault "en_US.UTF-8";
    };

    networking.firewall.enable = mkDefault true;
    networking.firewall.logRefusedConnections = mkDefault true;

    kampka.services.ntp.enable = mkDefault true;
    kampka.services.dns-cache.enable = mkDefault true;
}
