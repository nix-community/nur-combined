{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkDefault
    genAttrs
    const
    ;
  cfg = config.abszero.virtualisation.docker;
in

{
  options.abszero.virtualisation.docker.enable = mkEnableOption "docker";

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = mkDefault false;
    };
    users.users = genAttrs config.abszero.users.admins (const {
      extraGroups = [ "docker" ];
    });
  };
}
