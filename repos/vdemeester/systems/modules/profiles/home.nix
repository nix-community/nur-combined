{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.home;
  secretPath = ../../../secrets/machines.nix;
  secretCondition = (builtins.pathExists secretPath);
  machines = lib.optionalAttrs secretCondition (import secretPath);
in
{
  options = {
    profiles.home = mkEnableOption "Enable home profile";
  };
  config = mkIf cfg {
    boot.kernelParams = [ "nfs.nfs4_disable_idmapping=0" "nfsd.nfs4_disable_idmapping=0" ];
    networking = {
      domain = "home";
      hosts = with machines; mkIf secretCondition {
        "${home.ips.honshu}" = [ "honshu.home" ];
        "${wireguard.ips.honshu}" = [ "honshu.vpn" ];
        "${home.ips.shikoku}" = [ "shikoku.home" ];
        "${wireguard.ips.shikoku}" = [ "shikoku.vpn" ];
        "${home.ips.wakasu}" = [ "wakasu.home" ];
        "${wireguard.ips.wakasu}" = [ "wakasu.vpn" ];
        "${home.ips.hokkaido}" = [ "hokkaido.home" ];
        "${wireguard.ips.hokkaido}" = [ "hokkaido.vpn" ];
        "${home.ips.sakhalin}" = [ "sakhalin.home" ];
        "${wireguard.ips.sakhalin}" = [ "sakhalin.vpn" ];
        "${wireguard.ips.massimo}" = [ "massimo.vpn" ];
        "${home.ips.synodine}" = [ "synodine.home" ];
        "${home.ips.okinawa}" = [ "okinawa.home" ];
        "${wireguard.ips.okinawa}" = [ "okinawa.vpn" ];
        "${wireguard.ips.carthage}" = [ "carthage.vpn" ];
        "${wireguard.ips.kerkouane}" = [ "kerkouane.vpn" ];
      };
    };
    time.timeZone = "Europe/Paris";
    # To mimic autofs on fedora
    fileSystems = mkIf secretCondition {
      "/net/synodine.home/" = {
        device = "${machines.home.ips.synodine}:/";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" ];
      };
      # FIXME(vdemeester): I think it acts like this because there is only one export
      "/net/sakhalin.home/export/" = {
        device = "${machines.home.ips.sakhalin}:/";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" ];
      };
      # Deprecated
      "/mnt/synodine" = {
        device = "${machines.home.ips.synodine}:/";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" ];
      };
      "/mnt/sakhalin" = {
        device = "${machines.home.ips.sakhalin}:/";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" ];
      };
    };
  };
}
