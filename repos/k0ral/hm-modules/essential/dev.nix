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
      jwt-cli
      libxml2
      openssl
      patchelf
      pup
      yq
    ];

    programs = {
      jq.enable = true;
    };
  };
}
