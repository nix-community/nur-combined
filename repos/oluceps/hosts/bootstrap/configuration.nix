{ lib
, data
, modulesPath
, ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  time.timeZone = "America/Los_Angeles";
  networking.nameservers = [
    "8.8.8.8"
  ];


  users.mutableUsers = false;
  users.users.root = {
    hashedPassword = data.keys.hashedPasswd;
    openssh.authorizedKeys.keys = [
      data.keys.sshPubKey
      data.keys.skSshPubKey
    ];
  };

  systemd.network.enable = true;
  services.resolved.enable = false;

  systemd.network.networks.eth0 = {
    matchConfig.Name = "eth0";
    DHCP = "yes";
  };

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = lib.mkForce "prohibit-password";
    };
  };

  networking.firewall.enable = false;

  networking.useDHCP = false;

  networking.hostName = "bootstrap";

  system.stateVersion = "23.05";

  boot = {
    kernelParams = [
      "audit=0"
      "net.ifnames=0"

      "console=ttyS0"
      "earlyprintk=ttyS0"
      "rootdelay=300"
    ];
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/efi";
      };
      systemd-boot.enable = true;
      timeout = 3;
    };
    initrd = {
      compressor = "zstd";
      compressorArgs = [ "-19" "-T0" ];
      systemd.enable = true;

      kernelModules = [
        "hv_vmbus" # for hyper-V
        "hv_netvsc"
        "hv_utils"
        "hv_storvsc"
      ];

    };
  };
}
