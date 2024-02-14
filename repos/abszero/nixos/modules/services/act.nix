{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkPackageOption mkIf;
  cfg = config.abszero.services.act;
in

{
  imports = [ ../virtualisation/docker.nix ];

  options.abszero.services.act = {
    enable = mkEnableOption "local GitHub Actions runner";
    package = mkPackageOption pkgs "act" { };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    abszero.virtualisation.docker.enable = true; # FIXME: not working
  };
}
