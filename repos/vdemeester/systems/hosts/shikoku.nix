{ config, lib, pkgs, ... }:

with lib;
let
  hostname = "shikoku";
  secretPath = ../../secrets/machines.nix;
  secretCondition = (builtins.pathExists secretPath);

  ip = strings.optionalString secretCondition (import secretPath).wireguard.ips."${hostname}";
  ips = lists.optionals secretCondition ([ "${ip}/24" ]);
  endpointIP = strings.optionalString secretCondition (import secretPath).wg.endpointIP;
  endpointPort = if secretCondition then (import secretPath).wg.listenPort else 0;
  endpointPublicKey = strings.optionalString secretCondition (import secretPath).wireguard.kerkouane.publicKey;

  metadata = importTOML ../../ops/hosts.toml;

  gpuIDs = [
    "10de:1b80" # Graphics
    "10de:10f0" # Audio
  ];
in
{
  imports = [
    # (import ../../nix).home-manager-stable
    #../modules/default.stable.nix
    (import ../../users/vincent)
    (import ../../users/root)
  ];

  boot.supportedFilesystems = [ "zfs" ];
  networking = {
    hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);
    hostName = hostname;
    bridges.br1.interfaces = [ "enp0s31f6" ];
    firewall.enable = false; # we are in safe territory :D
    useDHCP = false;
    interfaces.br1 = {
      useDHCP = true;
    };
  };

  # TODO: check if it's done elsewhere
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
    
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [
    config.boot.kernelPackages.nvidiaPackages.stable
  ];
  boot.kernelParams = [
    "intel_iommu=on"
    "kvm_intel.nested=1"
    ("vfio-pci.ids=" + lib.concatStringsSep "," gpuIDs)
  ];

  hardware.opengl.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  # TODO: check if it's done elsewhere
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/73fd8864-f6af-4fdd-b826-0dfdeacd3c19";
    fsType = "ext4";
    options = [ "noatime" "discard" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/829D-BFD1";
    fsType = "vfat";
  };

  # Extra data
  # HDD:   b58e59a4-92e7-4278-97ba-6fe361913f50
  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/b58e59a4-92e7-4278-97ba-6fe361913f50";
    fsType = "ext4";
    options = [ "noatime" ];
  };
  # ZFS Pool
  # SSD1:  469077df-049f-4f5d-a34f-1f5449d782ec
  # SSD2:  e11a3b63-791c-418b-9f4b-5ae0199f1f97
  # NVME2: 3d2dff80-f2b1-4c48-8e76-12b01fdf4137
  # boot.zfs.extraPools = [ "tank" ];
  # networking.hostId = "03129692bea040488878aa0133e54914";
  # networking.hostId = "03129692";
  # fileSystems."/tank/data" =
  #   {
  #     device = "tank/data";
  #     fsType = "zfs";
  #     options = [ "zfsutil" ];
  #   };
  # 
  # fileSystems."/tank/virt" =
  #   {
  #     device = "tank/virt";
  #     fsType = "zfs";
  #     options = [ "zfsutil" ];
  #   };

  swapDevices = [{
    device = "/dev/disk/by-uuid/a9ec44e6-0c1d-4f60-9f5c-81a7eaa8e8fd";
  }];

  modules = {
    core.binfmt.enable = true;
    dev = {
      enable = false;
      containers = {
        docker = {
          enable = true;
          package = pkgs.docker_27;
        };
        podman.enable = true;
        buildkit = {
          enable = true;
          grpcAddress = [
            "unix:///run/buildkit/buildkitd.sock"
            "tcp://aomi.home:1234"
            "tcp://${metadata.hosts.shikoku.addrs.v4}:1234"
            "tcp://${metadata.hosts.shikoku.wireguard.addrs.v4}:1234"
          ];
        };
      };
    };
    services = {
      syncthing = {
        enable = true;
        guiAddress = "${metadata.hosts.shikoku.wireguard.addrs.v4}:8384";
      };
      avahi.enable = true;
      ssh.enable = true;
    };
    virtualisation.libvirt = { enable = true; nested = true; listenTCP = true; };
    profiles.home = true;
  };

  # environment.systemPackages = [ pkgs.python310Packages.aria2p ];

  programs.ssh.setXAuthLocation = true;

  sops.secrets.aria2RPCSecret = {
    mode = "444";
    owner = "aria2";
    group = "aria2";
  };
  
  services = {
    prometheus.exporters.node = {
      enable = true;
      port = 9000;
      enabledCollectors = [ "systemd" "processes" ];
      extraFlags = ["--collector.ethtool" "--collector.softirqs" "--collector.tcpstat"];
    };
    aria2 = {
      enable = true;
      openPorts = true;
      extraArguments = "--max-concurrent-downloads=20";
      downloadDir = "/data/downloads";
      rpcSecretFile = "${pkgs.writeText "aria" "aria2rpc\n"}";
      # rpcSecretFile = config.sops.secrets.aria2RPCSecret.path;
    };
    bazarr = {
      enable = true;
      # Use reverse proxy instead
      openFirewall = true;
    };
    radarr = {
      enable = true;
      # Use reverse proxy instead
      openFirewall = true;
    };
    sonarr = {
      enable = true;
      # Use reverse proxy instead
      openFirewall = true;
    };
    prowlarr = {
      enable = true;
      # Use reverse proxy instead
      openFirewall = true;
    };
    readarr = {
      enable = true;
      # Use reverse proxy instead
      openFirewall = true;
    };
    lidarr = {
      enable = true;
      # Use reverse proxy instead
      openFirewall = true;
    };
    netdata.enable = true;
    smartd = {
      enable = true;
      devices = [{ device = "/dev/nvme0n1"; }];
    };
    dockerRegistry = {
      enable = true;
      listenAddress = "0.0.0.0";
      port = 5000;
      enableDelete = true;
      enableGarbageCollect = true;
      garbageCollectDates = "daily";
    };
    wireguard = {
      enable = true;
      ips = ips;
      endpoint = endpointIP;
      endpointPort = endpointPort;
      endpointPublicKey = endpointPublicKey;
    };
  };

  # Move this to a "builder" role
  users.extraUsers.builder = {
    isNormalUser = true;
    uid = 1018;
    extraGroups = [ ];
    openssh.authorizedKeys.keys = [ (builtins.readFile ../../secrets/builder.pub) ];
  };
  nix.settings.trusted-users = [ "root" "vincent" "builder" ];

  security.pam.sshAgentAuth.enable = true;
}
