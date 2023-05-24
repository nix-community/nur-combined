{ config, lib, pkgs ? import <nixpkgs> { }, ... }:
with lib;

let cfg = config.module.essential.dev;
in {
  options.module.essential.dev = { enable = mkEnableOption "Essential development tools"; };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      binutils
      cacert
      httpie
      just
      libxml2
      openssl
      patchelf
      pup
    ];

    programs = {
      jq.enable = true;
    };
  };
}
