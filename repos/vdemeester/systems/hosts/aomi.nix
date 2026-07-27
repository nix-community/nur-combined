{ sources ? import ../../nix
, lib ? sources.lib
, pkgs ? sources.pkgs { }
, ...
}:

with lib;
let
  hostname = "aomi";
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
    ../hardware/lenovo-p1.nix
    (import ../../users/vincent)
    (import ../../users/root)
  ];

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/91b05f64-b97d-4405-8405-8785699ada8f";
      preLVM = true;
      allowDiscards = true;
      keyFile = "/dev/disk/by-id/mmc-SD08G_0x704a5a38";
      keyFileSize = 4096;
      fallbackToPassword = true;
    };
  };

  fileSystems."/" = {
    # device = "/dev/disk/by-uuid/6bedd234-3179-46f7-9a3f-feeffd880791";
    device = "/dev/mapper/root";
    fsType = "ext4";
    options = [ "noatime" "discard" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/32B9-94CC";
    fsType = "vfat";
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/24da6a46-cd28-4bff-9220-6f449e3bd8b5"; }];

  networking = {
    hostName = hostname;
    firewall.enable = false; # we are in safe territory :D
  };

  # extract this from desktop
  networking.networkmanager = {
    enable = true;
    unmanaged = [
      "interface-name:br-*"
      "interface-name:ve-*"
      "interface-name:veth*"
      "interface-name:wg0"
      "interface-name:docker0"
      "interface-name:virbr*"
    ];
    packages = with pkgs; [ networkmanager-openvpn ];
  };

  sops.defaultSopsFile = ../../secrets/secrets.yaml;

  boot = {
    loader.systemd-boot.netbootxyz.enable = true;
    kernelPackages = pkgs.linuxPackages_latest;
    tmpOnTmpfs = true;
  };

  services.hardware.bolt.enable = true;

  modules = {
    core.binfmt.enable = true;
    hardware = {
      laptop.enable = true;
    };
    dev = {
      enable = true;
      containers = {
        enable = true;
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
            "tcp://${metadata.hosts.aomi.addrs.v4}:1234"
            "tcp://${metadata.hosts.aomi.wireguard.addrs.v4}:1234"
          ];
        };
        image-mirroring = {
          enable = true;
          targets = [ "quay.io/vdemeest" "ghcr.io/vdemeester" ];
          settings = {
            "docker.io" = {
              "images" = {
                # sync latest and edge tags
                "alpine" = [ "latest" "edge" ];
              };
              "images-by-tag-regex" = {
                # sync all "3.x" images"
                "alpine" = "^3\.[0-9]+$";
              };
            };
          };
        };
      };
    };
    services = {
      avahi.enable = true;
      ssh.enable = true;
      syncthing = {
        enable = true;
        guiAddress = "${metadata.hosts.aomi.wireguard.addrs.v4}:8384";
      };
    };
    virtualisation.libvirt = { enable = true; nested = true; };
  };

  modules.profiles = {
    # externalbuilder.enable = true;
    home = true;
  };


  services.udev.extraRules = ''
    # STM32 rules for the Moonlander and Planck EZ
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", \
        MODE:="0666", \
        SYMLINK+="stm32_dfu"

    # Suspend the system when battery level drops to 5% or lower
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="${pkgs.systemd}/bin/systemctl hibernate"
  '';

  services = {
    envfs.enable = false;
    netdata.enable = true;
    logind.extraConfig = ''
      HandleLidSwitch=ignore
      HandleLidSwitchExternalPower=ignore
      HandleLidSwitchDocked=ignore
    '';
    prometheus.exporters.node = {
      enable = true;
      port = 9000;
      enabledCollectors = [ "systemd" "processes" ];
      extraFlags = ["--collector.ethtool" "--collector.softirqs" "--collector.tcpstat"];
    };
    smartd = {
      enable = true;
      devices = [{ device = "/dev/nvme0n1"; }];
    };
    wireguard = {
      enable = true;
      ips = [ "${metadata.hosts.aomi.wireguard.addrs.v4}/24" ];
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
  nix.trustedUsers = [ "root" "vincent" "builder" ];

  # RedHat specific
  systemd.services.osp-vdemeest-nightly = {
    description = "Build nightly builds";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];

    restartIfChanged = false;
    unitConfig.X-StopOnRemoval = false;

    serviceConfig = {
      Type = "oneshot";
      User = "vincent";
      OnFailure = "status-email-root@%.service";
    };

    path = with pkgs; [ git openssh bash coreutils-full nix which gnumake ];
    script = ''
      set -e
      cd /home/vincent/src/osp/p12n/p12n
      git fetch -p --all
      git clean -fd
      git reset --hard HEAD
      git checkout main
      git rebase upstream/main
      # Make versions
      make versions
      for v in 1.7 1.8 1.9 1.10; do
        echo "Build $v"
        (
        cd versions/$v
        git clean -fd
        git reset --hard HEAD
        git co upstream/pipelines-$v-rhel-8
        nix-shell /home/vincent/src/osp/shell.nix --command "make REMOTE=quay.io/vdemeest TAG=$v sources/upgrade sources/operator/fetch-payload  bundle/push"
        )
      done
    '';

    startAt = "daily";
  };
  security.pam.enableSSHAgentAuth = true;
}
