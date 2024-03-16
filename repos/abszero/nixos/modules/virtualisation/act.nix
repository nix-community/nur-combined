{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkPackageOption mkIf;
  cfg = config.abszero.virtualisation.act;
in

{
  imports = [ ../virtualisation/docker.nix ];

  options.abszero.virtualisation.act = {
    enable = mkEnableOption "local GitHub Actions runner";
    package = mkPackageOption pkgs "act" { };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    abszero.virtualisation.docker.enable = true;
  };
}
