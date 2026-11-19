{
  inputs,
  lib,
  self,
  ...
}:
{
  os.rescue.module =
    { pkgs, ... }:
    {
      imports = [
        (inputs.nixpkgs.outPath + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")

        {
          nixpkgs = {
            hostPlatform = "x86_64-linux";
            overlays = [ self.overlays.kernel ];
          };
        }
      ];
      networking = {
        # wireless.iwd.enable = true;
        # wireless.enable = false;
        useNetworkd = true;
        networkmanager.enable = lib.mkForce false;
        useDHCP = true;
        firewall.enable = false;
        enableIPv6 = true;
        nftables.enable = true;
      };
      # Match the installed storage stack rather than using the testing kernel,
      # which may not have a compatible ZFS module.
      boot = {
        kernelPackages = lib.mkForce pkgs.linuxPackages_6_18;
        supportedFilesystems = [
          "zfs"
          "btrfs"
          "vfat"
        ];
        zfs.forceImportAll = false;
        zfs.forceImportRoot = false;
        kernelModules = [
          "ipmi_devintf"
          "ipmi_si"
        ];
        blacklistedKernelModules = [ "ipmi_watchdog" ];
        kernelParams = [ "consoleblank=0" ];
      };
      # ZFS requires a host ID; pool imports remain an explicit recovery step.
      networking.hostId = "8425e349";
      systemd.settings.Manager = {
        RuntimeWatchdogSec = "0";
        RebootWatchdogSec = "0";
      };
      systemd.services.rescue-watchdog-off = {
        description = "Disarm the BMC watchdog during recovery";
        wantedBy = [ "multi-user.target" ];
        wants = [ "systemd-udev-settle.service" ];
        after = [ "systemd-udev-settle.service" ];
        unitConfig.ConditionPathExists = "/dev/ipmi0";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.ipmitool}/bin/ipmitool mc watchdog off";
        };
      };

      isoImage = {
        compressImage = true;
        squashfsCompression = "zstd -Xcompression-level 6";
      };
      programs.fish.enable = true;
      users.users.root.openssh.authorizedKeys.keys = with self.data.keys; [
        sshPubKey
        skSshPubKey
      ];

      systemd.services.nix-daemon = {
        serviceConfig.LimitNOFILE = lib.mkForce 500000000;
      };
      nix = {
        package = pkgs.nixVersions.stable;
        nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
        channel.enable = false;
        registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

        settings = {
          system-features = [
            "nixos-test"
            "benchmark"
            "big-parallel"
            "kvm"
          ]
          ++ [ "gccarch-znver3" ];
          flake-registry = "";
          nix-path = [ "nixpkgs=${inputs.nixpkgs}" ];
          keep-outputs = true;
          keep-derivations = true;
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
            "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
            "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
          ];
          extra-substituters = [
            "https://cache.lix.systems"
          ]
          ++ (map (n: "https://${n}.cachix.org") [
            "nix-community"
            "helix"
            "nixpkgs-wayland"
          ]);
          substituters = [
            "https://cache.nixos.org"
            "https://cache.garnix.io"
          ];
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
            "auto-allocate-uids"
            "cgroups"
            # "recursive-nix"
            # "ca-derivations"
            # "pipe-operator"
            "pipe-operators"
          ];
          auto-allocate-uids = true;
          use-cgroups = true;

          trusted-users = [
            "root"
          ];
          # Avoid disk full
          max-free = lib.mkDefault (1000 * 1000 * 1000);
          min-free = lib.mkDefault (128 * 1000 * 1000);
          builders-use-substitutes = true;
          allow-import-from-derivation = true;
        };

        daemonCPUSchedPolicy = lib.mkDefault "batch";
        daemonIOSchedClass = lib.mkDefault "idle";
        daemonIOSchedPriority = lib.mkDefault 7;

      };

      services = {
        # sing-box = {
        #   enable = true;
        #   configFile = lib.readToStore "/run/vaultix/sing";
        # };
        pcscd.enable = true;
        openssh.enable = true;
      };

      environment.systemPackages =
        with pkgs;
        [
          (writeShellScriptBin "mount-os" ''
            set -euo pipefail
            device="''${1:?Usage: mount-os <block-device> [mountpoint]}"
            target="''${2:-/mnt}"
            case "$device" in
              /dev/*) ;;
              *) device="/dev/$device" ;;
            esac
            mkdir -p "$target"/{persist,var,efi,nix}
            for subvol in nix persist var; do
              mount -t btrfs -o "ro,rescue=nologreplay,subvol=$subvol" "$device" "$target/$subvol"
            done
            echo "Persistent subvolumes mounted read-only under $target; EFI is not mounted."
          '')
          btrfs-progs
          zfs
          ipmitool
          rsync
          gptfdisk
          dosfstools
          sqlite
          nftables
          tor
          iperf3
          i2p
          ethtool
          dnsutils
          tcpdump
          tmux
          sing-box
          netcat
          wget
          mtr-gui
          hysteria
          foot
          socat
          arti
          miniserve
          mtr
          wakelan
          q
          nali
          lynx
          nethogs
          w3m
          whois
          dig
          wireguard-tools
          # curlHTTP3

          srm

          killall
          # common
          hexyl
          jq
          cage
          fx
          bottom
          lsd
          fd
          choose
          duf
          tokei
          procs

          lsof
          tree
          bat

          broot
          powertop
          ranger

          ripgrep

          qrencode
          lazygit
          b3sum
          unzip
          zip
          coreutils

          bpftools
          # inetutils
          pciutils
          usbutils
          wezterm
        ]
        ++ [
          rage
          age-plugin-yubikey
          # yubikey-manager
          # yubikey-manager-qt
          gnupg
          cryptsetup
        ];
    };
}
