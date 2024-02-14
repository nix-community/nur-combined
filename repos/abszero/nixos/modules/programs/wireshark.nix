{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf const genAttrs;
  cfg = config.abszero.programs.wireshark;
in

{
  options.abszero.programs.wireshark.enable = mkEnableOption "network protocol analyzer";

  config = mkIf cfg.enable
    {
      environment.systemPackages = with pkgs; [ wireshark ];
      users.users = genAttrs
        config.abszero.users.admins
        (const { extraGroups = [ "wireshark" ]; });
    };
}
