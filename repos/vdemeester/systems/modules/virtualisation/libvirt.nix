{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.modules.virtualisation.libvirt;
in
{
  options.modules.virtualisation.libvirt = {
    enable = mkEnableOption "Enable libvirt";
    nested = mkEnableOption "Enable nested virtualisation (kvm)";
    listenTCP = mkEnableOption "Expose and make libvirt to a TCP port";
  };
  config = mkIf cfg.enable (mkMerge [
    {
      virtualisation.libvirtd = {
        enable = true;
        # Used for UEFI boot of Home Assistant OS guest image
        qemu.ovmf.enable = true;
      };
      security.polkit.enable = true; # 22.11: libvirtd requires poltkit to be enabled
      environment.systemPackages = with pkgs; [ qemu vde2 libosinfo ];
    }
    (mkIf config.modules.desktop.enable {
      environment.systemPackages = with pkgs; [ virt-manager ];
    })
    (mkIf cfg.nested {
      boot.kernelParams = [ "kvm_intel.nested=1" ];
      environment.etc."modprobe.d/kvm.conf".text = ''
        options kvm_intel nested=1
      '';
    })
    (mkIf cfg.listenTCP {
      boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };
      virtualisation.libvirtd = {
        allowedBridges = [ "br1" ];
        extraConfig = ''
          listen_tls = 0
          listen_tcp = 1
          auth_tcp="none"
          tcp_port = "16509"
        '';
        # extraOptions = [ "--listen" ];
      };
      networking.firewall.allowedTCPPorts = [ 16509 ];
    })
  ]);
}
