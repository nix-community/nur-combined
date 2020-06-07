{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.home;
in
{
  options = {
    profiles.home = mkEnableOption "Enable home profile";
  };
  config = mkIf cfg {
    boot.kernelParams = [ "nfs.nfs4_disable_idmapping=0" "nfsd.nfs4_disable_idmapping=0" ];
    networking.domain = "home";
    time.timeZone = "Europe/Paris";
    # To mimic autofs on fedora
    fileSystems = with import ../../assets/machines.nix; {
      "/net/synodine.home/" = {
        device = "${home.ips.synodine}:/";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" ];
      };
      # FIXME(vdemeester): I think it acts like this because there is only one export
      "/net/sakhalin.home/export/" = {
        device = "${home.ips.sakhalin}:/";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" ];
      };
      # Deprecated
      "/mnt/synodine" = {
        device = "${home.ips.synodine}:/";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" ];
      };
      "/mnt/sakhalin" = {
        device = "${home.ips.sakhalin}:/";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" ];
      };
    };
  };
}
