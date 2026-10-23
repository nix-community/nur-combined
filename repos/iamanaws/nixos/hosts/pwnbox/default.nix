{
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./display.nix
  ];

  users.users = {
    iamanaws = {
      initialPassword = "password123!";
      openssh.authorizedKeys.keys = [
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    ################
    ##  utilities ##
    ################
    bat
    dig
    gobuster
    hashcat
    netcat-openbsd
    ngrep
    nmap
    openvpn
    samba
    subfinder
    whatweb

    awscli2
    bettercap
    caido-desktop
    cyberchef
    # ghidra
    # metasploit
    # rizin
    # rizinPlugins.rz-ghidra

    ################
    ##    devel   ##
    ################
    go
    python3

    ################
    ##  wordlists ##
    ################
    wordlists
  ];

  virtualisation.vmVariant =
    { config, ... }:
    {
      virtualisation = {
        cores = 6;
        memorySize = 8192;
        # macOS uses QEMU's native Cocoa display; GTK/clipboard support is Linux-only.
        qemu.options = lib.optionals config.virtualisation.host.pkgs.stdenv.hostPlatform.isLinux [
          "-display gtk,zoom-to-fit=true"
          # "-display vnc=localhost:0"
          "-chardev qemu-vdagent,id=ch1,name=vdagent,clipboard=on"
          "-device virtio-serial-pci"
          "-device virtserialport,chardev=ch1,id=ch1,name=com.redhat.spice.0"
        ];

        spiceUSBRedirection.enable = false;

        # mkdir -p ~/vms/pwnbox/shared, then nix run .#pwnbox.
        # macOS launchers need a Linux builder or cached guest outputs.
        sharedDirectories.hostshare = {
          source = "$HOME/vms/pwnbox/shared";
          target = "/mnt/hostshare";
          writable = true;
        };
      };
    };

  # Required root filesystem definition for successful NixOS evaluation.
  # Using a disk label is a sensible default; override if needed per deployment.
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  services.spice-vdagentd.enable = true;
  environment.etc.hosts.mode = "0644";

}
