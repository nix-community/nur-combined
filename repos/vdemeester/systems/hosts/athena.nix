{ pkgs, lib, ... }:

with lib;
let
  hostname = "athena";
  secretPath = ../../secrets/machines.nix;
  secretCondition = (builtins.pathExists secretPath);

  ip = strings.optionalString secretCondition (import secretPath).wireguard.ips."${hostname}";
  ips = lists.optionals secretCondition ([ "${ip}/24" ]);
  endpointIP = strings.optionalString secretCondition (import secretPath).wg.endpointIP;
  endpointPort = if secretCondition then (import secretPath).wg.listenPort else 0;
  endpointPublicKey = strings.optionalString secretCondition (import secretPath).wireguard.kerkouane.publicKey;

  metadata = importTOML ../../ops/hosts.toml;
in
{
  imports = [
    (import ../../users/vincent)
    (import ../../users/root)
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking = {
    hostName = hostname;
    firewall.enable = false; # we are in safe territory :D
    # bridges.br1.interfaces = [ "enp0s31f6" ];
    # useDHCP = false;
    # interfaces.br1 = {
    #   useDHCP = true;
    # };
  };

  core.boot.systemd-boot = lib.mkForce false;
  # boot.cleanTmpDir = lib.mkForce false;
  # boot.loader.systemd-boot.enable = lib.mkForce false;
  # profiles.base.systemd-boot = lib.mkForce true;
  # 
  modules = {
    profiles.home = true;
    services = {
      bind.enable = true;
      #     syncthing = {
      #       enable = true;
      #       guiAddress = "${metadata.hosts.sakhalin.wireguard.addrs.v4}:8384";
      #     };
      avahi.enable = true;
      ssh.enable = true;
    };
  };

  services = {
    prometheus.exporters = {
      node = {
	enable = true;
	port = 9000;
	enabledCollectors = [ "systemd" "processes" ];
	extraFlags = ["--collector.ethtool" "--collector.softirqs" "--collector.tcpstat"];
      };
      bind = { enable = true; port = 9009; };
    };
    wireguard = {
      enable = true;
      ips = ips;
      endpoint = endpointIP;
      endpointPort = endpointPort;
      endpointPublicKey = endpointPublicKey;
    };
  };
  security.apparmor.enable = true;
  security.pam.enableSSHAgentAuth = true;
}
