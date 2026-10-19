{
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  nix-mineral.enable = false;
  networking.hostName = "iso";
  # ZFS refuses to load without one. Fixed rather than random so a stick that
  # imports a pool twice does not look like two different machines.
  networking.hostId = "15015015";

  # A rescue stick that cannot read the filesystems it is rescuing is a coaster.
  # bcachefs is out-of-tree as of 6.18, so it is absent from stock install media;
  # this is the whole reason for rolling our own.
  boot.supportedFilesystems = {
    bcachefs = true;
    zfs = true;
    ntfs = true;
    ext4 = true;
    sshfs = true;
  };
  # Never force-import a pool on rescue media. If a pool looks like it is still
  # owned by another host, that is information, not an obstacle to bulldoze.
  boot.zfs.forceImportRoot = false;

  # Reaching the stick over the tailnet beats reading a console over someone's
  # shoulder. No auth key is baked in: a USB stick is a losable object, and a
  # reusable key on one is a standing credential for anybody who finds it.
  # Instead the stick prints a login URL and a QR code on tty1 at boot; one
  # click authenticates it, and --ssh means no key juggling afterwards.
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  systemd.services.tailscale-rescue-login = {
    description = "Bring the rescue stick onto the tailnet and print a login QR";
    after = [
      "tailscaled.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    requires = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StandardOutput = "tty";
      TTYPath = "/dev/tty1";
    };
    script = ''
      ${pkgs.tailscale}/bin/tailscale up \
        --ssh \
        --accept-routes \
        --hostname="rescue-$(${pkgs.coreutils}/bin/head -c4 /proc/sys/kernel/random/uuid)" \
        --qr || true
      echo
      echo "tailnet address: $(${pkgs.tailscale}/bin/tailscale ip -4 2>/dev/null || echo 'not connected')"
    '';
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPm9/uwsYQ2KrzaVcpulcDUKnBOCMCYogfC+D+TcrK7"
  ];

  environment.systemPackages = with pkgs; [
    # Filesystems
    bcachefs-tools
    zfs
    e2fsprogs
    dosfstools
    ntfs3g
    btrfs-progs
    xfsprogs

    # Encryption / storage
    cryptsetup
    lvm2
    mdadm
    ddrescue
    testdisk

    # Disks / hardware
    gptfdisk
    parted
    smartmontools
    nvme-cli
    hdparm
    pciutils
    usbutils
    lshw
    dmidecode
    lm_sensors
    i2c-tools
    efibootmgr

    # Network
    iproute2
    ethtool
    tcpdump
    nmap
    bind
    openssh
    wget
    curl
    socat
    mtr
    traceroute

    # Network filesystems
    cifs-utils
    nfs-utils
    sshfs

    # Data movement
    rsync

    # Nix
    nixos-rebuild
    nix-output-monitor

    # General
    git
    jq
    ripgrep
    fd
    tree
    less
    htop
    btop
    ncdu
    lsof
    strace
    file
    tmux
    vim
    zip
    unzip
  ];
  system.stateVersion = lib.trivial.release;
}
