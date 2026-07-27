{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.profiles.home;
  secretPath = ../../../secrets/machines.nix;
  secretCondition = (builtins.pathExists secretPath);
  machines = lib.optionalAttrs secretCondition (import secretPath);
in
{
  options = {
    modules.profiles.home = mkEnableOption "Enable home profile";
  };
  config = mkIf cfg {
    boot.kernelParams = [ "nfs.nfs4_disable_idmapping=0" "nfsd.nfs4_disable_idmapping=0" ];
    networking = {
      domain = "home";
      hosts = with machines; mkIf secretCondition {
        "${home.ips.honshu}" = [ "honshu.home" ];
        "${home.ips.aion}" = [ "aion.home" ];
        "${home.ips.aomi}" = [ "aomi.home" ];
        "${wireguard.ips.aomi}" = [ "aomi.vpn" ];
        "${home.ips.shikoku}" = [ "shikoku.home" ];
        "${wireguard.ips.shikoku}" = [ "shikoku.vpn" ];
        "${home.ips.wakasu}" = [ "wakasu.home" ];
        "${wireguard.ips.wakasu}" = [ "wakasu.vpn" ];
        "${home.ips.hokkaido}" = [ "hokkaido.home" ];
        "${wireguard.ips.hokkaido}" = [ "hokkaido.vpn" ];
        # "${home.ips.sakhalin}" = [ "sakhalin.home" ];
        "${home.ips.sakhalin}" = [ "sakhalin.home" "nix.cache.home" ];
        "${wireguard.ips.sakhalin}" = [ "sakhalin.vpn" ];
        "${home.ips.synodine}" = [ "synodine.home" ];
        "${home.ips.okinawa}" = [ "okinawa.home" ];
        "${wireguard.ips.okinawa}" = [ "okinawa.vpn" ];
        "${wireguard.ips.kerkouane}" = [ "kerkouane.vpn" ];
        "${wireguard.ips.naruhodo}" = [ "naruhodo.vpn" ];
        "${home.ips.demeter}" = [ "demeter.home" ];
        "${home.ips.athena}" = [ "athena.home" ];
      };
    };
    time.timeZone = "Europe/Paris";
    # To mimic autofs on fedora
    fileSystems = mkIf secretCondition {
      "/net/synodine.home" = {
        device = "${machines.home.ips.synodine}:/";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" ];
      };
      # FIXME(vdemeester): I think it acts like this because there is only one export
      "/net/sakhalin.home/export" = {
        device = "${machines.home.ips.sakhalin}:/";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" ];
      };
      # FIXME(vdemeester): Loop
      "/net/aion.home/export/documents" = {
        device = "aion.home:/export/documents";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" ];
      };
      "/net/aion.home/export/downloads" = {
        device = "aion.home:/export/downloads";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" ];
      };
      "/net/aion.home/export/music" = {
        device = "aion.home:/export/music";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" ];
      };
      "/net/aion.home/export/pictures" = {
        device = "aion.home:/export/pictures";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" ];
      };
      "/net/aion.home/export/videos" = {
        device = "aion.home:/export/videos";
        fsType = "nfs";
        options = [ "x-systemd.automount" "noauto" ];
      };
    };
  };
}
