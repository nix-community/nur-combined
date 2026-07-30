{ config,pkgs, lib, ... }:

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
      extraPackages = with pkgs; [ nftables ];
      extraOptions = "--firewall-backend=nftables";
    };
    users.users = genAttrs config.abszero.users.admins (const {
      extraGroups = [ "docker" ];
    });
  };
}
