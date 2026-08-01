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
    caido
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

  virtualisation.vmVariant.virtualisation = {
    qemu.options = [
      "-smp 6"
      "-m 8192"
      "-display gtk,zoom-to-fit=true"
      # "-display vnc=localhost:0"
      "-chardev qemu-vdagent,id=ch1,name=vdagent,clipboard=on"
      "-device virtio-serial-pci"
      "-device virtserialport,chardev=ch1,id=ch1,name=com.redhat.spice.0"
    ];

    spiceUSBRedirection.enable = false;

    sharedDirectories = {
      hostshare = {
        source = "$HOME/vms/pwnbox/shared";
        target = "/mnt/hostshare";
      };
    };
  };

  environment.etc."tmpfiles.d/hostshare.conf".text = ''
    d /mnt/hostshare 0755 root root -
  '';

  # Required root filesystem definition for successful NixOS evaluation.
  # Using a disk label is a sensible default; override if needed per deployment.
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Define the filesystem mount for the shared directory within the guest
  fileSystems."/mnt/hostshare" = {
    device = "hostshare";
    fsType = "9p";
    options = [
      "trans=virtio" # Use virtio transport
      "version=9p2000.L" # Use the Linux extensions for 9p
      "_netdev" # Indicate it's a network device (prevents mount issues at boot)
      "nofail" # Prevent boot failure if the share isn't available
      "rw" # Mount read-write
      "uid=1000"
      "gid=100"
    ];
  };

  services.spice-vdagentd.enable = true;
  environment.etc.hosts.mode = "0644";

}
