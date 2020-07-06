{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.virtualization;
in
{
  options = {
    profiles.virtualization = {
      enable = mkOption { default = false; description = "Enable virtualization profile"; type = types.bool; };
      nested = mkOption {
        default = false;
        description = "Enable nested virtualization";
        type = types.bool;
      };
      listenTCP = mkOption {
        default = false;
        description = "Make libvirt listen to TCP";
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      virtualisation.libvirtd = {
        enable = true;
      };
      environment.systemPackages = with pkgs; [
        qemu
        vde2
        libosinfo
      ];
    }
    (
      mkIf cfg.nested {
        boot.kernelParams = [ "kvm_intel.nested=1" ];
        environment.etc."modprobe.d/kvm.conf".text = ''
          options kvm_intel nested=1
        '';
      }
    )
    (
      mkIf config.profiles.desktop.enable {
        environment.systemPackages = with pkgs; [ virtmanager ];
      }
    )
    (
      mkIf cfg.listenTCP {
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
      }
    )
  ]);
}
