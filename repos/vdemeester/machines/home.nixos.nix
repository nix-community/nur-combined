{ config, pkgs, ... }:

with import ../assets/machines.nix; {
  boot.kernelParams = [ "nfs.nfs4_disable_idmapping=0" "nfsd.nfs4_disable_idmapping=0" ];
  networking.domain = "home";
  time.timeZone = "Europe/Paris";
  # To mimic autofs on fedora
  fileSystems."/net/synodine.home/" = {
    device = "${home.ips.synodine}:/";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
  # FIXME(vdemeester): I think it acts like this because there is only one export
  fileSystems."/net/sakhalin.home/export/" = {
    device = "${home.ips.sakhalin}:/";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
  # Deprecated
  fileSystems."/mnt/synodine" = {
    device = "${home.ips.synodine}:/";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
  fileSystems."/mnt/sakhalin" = {
    device = "${home.ips.sakhalin}:/";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
}
