
{ inputs, pkgs, secretsDir, config, dataDir, ... }: let

in {

  #disabledModules = [ "services/databases/couchdb.nix" ];
	imports = [
    #"${inputs.nixpkgs-unstable}/nixos/modules/services/databases/couchdb.nix"
		../common/all.nix
		../common/nixos.nix
    ../common/building.nix

		inputs.home-manager.nixosModules.home-manager
    ../users/me/headless.nix
    ../users/root/default.nix
    ../users/files/headless.nix
    ../users/server/headless.nix

    inputs.arion.nixosModules.arion
    ../mods/fusu-services.nix
	];

  # mac address for wakeonlan: 00:19:99:fd:28:23

  # allow acern to ssh into server
  #users.users.server.openssh.authorizedKeys.keys = [
    #"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHTV1VoNAjMha5IP+qb8XABDo02pW3iN0yPBIbSqZA27 me@acern"
  #];

  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    qemuSwtpm = true;
  };
  # store libvirt data in dataDir
	fileSystems."/var/lib/libvirt" = {
		device = "/home/me/host/libvirt";
  	options = [ "bind" ];
	};

  

  # allow server user to shutdown fusu
  #security.sudo.extraRules = [
    #{
      #users = [ "server" ];
      #commands = [ { command = "/run/current-system/sw/bin/shutdown"; options = [ "SETENV" "NOPASSWD" ]; } ];
    #}
  #];

  


  services.tailscale.enable = true;


  services.resilio = {
    enable = true;
    enableWebUI = true;
    httpListenAddr = "100.70.54.18";
    checkForUpdates = false;
    listeningPort = 44444;
  };
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    44444 # resilio sync
    9000 # resilio webui
    9001 # fwin vnc
    9002 # fwin rdp
    9003 # fwin ssh
  ];
  networking.firewall.interfaces."br0".allowedTCPPorts = [
    44444 # resilio sync
    9000 # resilio webui
    9001 # fwin vnc
    9002 # fwin rdp
    9003 # fwin ssh
  ];


  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.package = pkgs.zfs_unstable;
  boot.zfs.forceImportRoot = false;
  networking.hostId = "7552c83e";

  fileSystems."/home/files/storage" = {
    device = "storage";
    fsType = "zfs";
  };

	# Use the GRUB 2 boot loader.
	boot.loader.grub = {
  	enable = true;
    #device = "/dev/disk/by-id/ata-TOSHIBA_MQ04ABF100_11MYT5RBT";
    device = "nodev"; # don't install, when i do nixre -h fusu ... but when installing onto the two discs (sata hdd and nvme ssd) change to the device like above
  	efiSupport = false;
		extraConfig = ''
			set timeout=2
		'';
  };

  #fileSystems."/boot" = {
  #  device = "/dev/disk/by-label/fusu-boot";
  #  fsType = "fat32";
  #};

	services.openssh = {
  		enable = true;
  		# require public key authentication for better security
  		settings.PasswordAuthentication = false;
  		settings.KbdInteractiveAuthentication = false;
  		settings.PermitRootLogin = "yes";
      ports = [ 49388 ];

      settings.X11Forwarding = true;

      extraConfig = ''
        X11UseLocalhost no
      '';
	};

	networking.firewall.allowPing = true;
	networking.firewall.enable = true;

	services.samba.openFirewall = true;

	networking.firewall.allowedTCPPorts = [
		8888 # for general usage
		9999 # for general usage
    8080 # for mitm proxy
    5901 # vnc

  	5357 # wsdd
    8080 # for mitm proxy

    49388
    49389
    49390
    49391
    49392
    49393

	];


  networking.firewall.allowedTCPPortRanges = [
    { from = 25500; to = 27777;} # minecraft
  ];
  networking.firewall.allowedUDPPortRanges = [
    { from = 27700; to = 28800;} # minecraft
  ];

	networking.firewall.allowedUDPPorts = [
  		3702 # wsdd
      67 # allow DHCP traffic
      53 # allow dns
	];

  networking.networkmanager.enable = false;  # Easiest to use and most distros use this by default.

  # to build rpi images
  boot.binfmt.emulatedSystems = [ 
    "aarch64-linux"
  ];

  environment.systemPackages = with pkgs; [
    sshfs
    ntfs3g
    virtiofsd
    bcache-tools
    su
    fuse3
    terraform
    usbutils
    qemu_full
    libvirt
  ];

	nix.settings = {
		trusted-public-keys = [
			"sebastian@c2vi.dev:0tIXGRJMLaI9H1ZPdU4gh+BikUuBVHtk+e1B5HggdZo="
		];
      trusted-users = [ "me" ];
	};


  networking.useDHCP = false;
  networking.bridges = {
    "br0" = {
      interfaces = [ "enp0s25" ];
    };
  };
  networking.interfaces.br0.ipv4.addresses = [ {
    address = "192.168.1.2";
    prefixLength = 24;
  } ];
	networking = {
		usePredictableInterfaceNames = true;
		defaultGateway = {
			address = "192.168.1.1";
			interface = "br0";
		};
		hostName = "fusu";
		nameservers = [ "1.1.1.1" "8.8.8.8" ];
	};



  ############################ couchdb for Obsidian Live sync
  #services.couchdb.enable = true;
  #services.couchdb.extraConfigFiles = [ "/home/files/storage/files/stuff/obsidian-live-sync/local.ini" ];
  #services.couchdb.databaseDir = "/home/files/storage/files/stuff/obsidian-live-sync/data";



  ############################ update ip service

  systemd.services.update-ip = 
    let 
    update-ip = pkgs.writeShellApplication {
      name = "update-ip";

      runtimeInputs = with pkgs; [ curl w3m ];

      text = ''
        ip=$(curl -4 my.ip.fi)
        curl "http://dynv6.com/api/update?hostname=${builtins.readFile "${secretsDir}/dns-name-two"}&ipv4=$ip&token=${builtins.readFile "${secretsDir}/dns-name-two-token"}"
        curl "https://dynamicdns.park-your-domain.com/update?host=home&domain=${builtins.readFile "${secretsDir}/dns-name"}&password=${builtins.readFile "${secretsDir}/dns-name-token"}&ip=$ip"

        # https://www.namecheap.com/support/knowledgebase/article.aspx/29/11/how-to-dynamically-update-the-hosts-ip-with-an-https-request/
      '';
      };
      #curl "https://dynamicdns.park-your-domain.com/update?host=mc&domain=c2vi.dev&password=${builtins.readFile "${secretsDir}/dns-name-token"}&ip=$ip"
    in
  {
    enable = true;
    description = "dyndns ip updates";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      Restart = "always";
      RestartSec = "500s";
      ExecStart = "${update-ip}/bin/update-ip";
    };
    wantedBy = [ "multi-user.target" ];
  };
  






  ###################################### get oci ampere vm ####################################

  systemd.services.oci-ampere = 
    let 
    oci-ampere = pkgs.writeShellApplication {
      name = "oci-ampere";

      runtimeInputs = with pkgs; [ terraform ];

      text = ''
        if [[ -f /home/me/here/oci-ampere-vm/not_gotten ]]
        then
          echo not gotten....................................
          pwd
          cd /home/me/here/oci-ampere-vm
          terraform apply -auto-approve && rm /home/me/here/oci-ampere-vm/not_gotten
        else
          echo gotten!!!!!!!!!!!!!!!!!!!!!
        fi
      '';
      };
    in
  {
    enable = false;
    description = "get a oci ampere vm";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      Restart = "always";
      RestartSec = "500s";
      ExecStart = "${oci-ampere}/bin/oci-ampere";
    };
    wantedBy = [ "multi-user.target" ];
  };


	################################ samba ######################################
	services.samba-wsdd.enable = true; # make shares visible for windows 10 clients

  # needed see: [[samba problems]] in my obsidian vault
  users.users.files.group = "files";
  users.groups.files = {};

	services.samba = {
    enable = true;
    securityType = "user";
    settings = {
      global = {
        "server role" = "standalone server";
        "map to guest" = "bad user";
        "usershare allow guests" = "yes";
        # "hosts allow" = "192.168.1 127.0.0.1 localhost";
        # "hosts deny" = "0.0.0.0/0";
        "workgroup" = "WORKGROUP";
        "security" = "user";
      };
      files = {
        "valid users" = "files";
        "comment" = "all my files";
        "path" = "/home/files/storage/files";
        "browsable" = "no";
        "read only" = "no";
        "guest ok" = "no";
        "force user" = "files";
        "force group" = "files";
        "force create mode" = "0777";
        # Papierkorb
        "vfs object" = "recycle";
        "recycle:repository" = "/home/files/storage/files/trash-files";
        "recycle:keeptree" = "Yes";
        "recycle:versions" = "Yes";
        "recycle:touch" = "Yes";
        "recycle:touch_mtime" = "Yes";
        "recycle:maxsize" = "80000";
      };
      lan = {
        "comment" = "gastordner";
        "path" = "/home/files/storage/lan";
        "read only" = "no";
        "guest ok" = "yes";
        "force user" = "files";
        "force group" = "files";
        "force create mode" = "0777";
        # Papierkorb
        "vfs object" = "recycle";
        "recycle:repository" = "/home/files/storage/files/trash-lan";
        "recycle:keeptree" = "No";
        "recycle:versions" = "Yes";
        "recycle:touch" = "Yes";
        "recycle:touch_mtime" = "Yes";
        "recycle:maxsize" = "8000";
      };

      mama = {
        "comment" = "Meine Dateien auf Mamas Laptop";
        "path" = "/home/files/storage/files/stuff/Mamas-Laptop";
        "browsable" = "no";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "mamafiles";
        "force user" = "files";
        "force group" = "files";
        "force create mode" = "0777";
      };
    };
  };

  ############################## backup to onedrive ##################################
  # needs that
  programs.fuse.userAllowOther = true; # otherwise the root user has no acces to the mount

  systemd.services.rclone-mount-backup = {
    enable = false;
    description = "Mount rclone backup folder";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c 'export PATH=/run/wrappers/bin:$PATH; id; ${pkgs.rclone}/bin/rclone mount --allow-non-empty --allow-other --vfs-cache-max-size 2G --vfs-cache-mode full backup: /home/files/backup'";
      User = "files";
      Group = "files";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.borgbackup.jobs.files = {
    #user = "files";
    extraCreateArgs = "--verbose --list --filter=AMECbchfs --stats --checkpoint-interval 600";
    extraArgs = "--progress";
    paths = "/home/files/storage";
    doInit = false;
    repo = "/home/files/backup/dateien-backup-borg-repo";
    compression = "lzma,9";
    startAt = "weekly";
    user = "files";
    group = "files";
    postCreate = ''
      echo create done!!!!!
    '';
    extraPruneArgs = "--stats --list --save-space";
    patterns = [
      "- /home/files/storage/files/no-backup"
    ];

    encryption.mode = "repokey-blake2";
    encryption.passCommand = "cat /home/files/secrets/borg-passphrase";

    environment.BORG_KEY_FILE = "/home/files/secrets/borg-key";

    prune.keep = {
      #within = "1w"; # Keep all archives from the last day
      daily = 7;
      weekly = 7;
      monthly = -1;  # Keep at least one archive for each month
    };

  };

  ############################## backups to fusu ##################################

  users.users.borgs = {
    uid = 2000;
    isNormalUser = true;
    group = "borgs";
  };
  users.groups.borgs = {
    gid = 2000;
  };
  home-manager.users.borgs =  { secretsDir, ... }: {

    imports = [
      ../users/common/home.nix
    ];

    home.file.".ssh/known_hosts".text = ''
      195.201.148.94 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBuxoYAjNYi3q2SFlzoVQTePcsnmT+qFHuaiiclC+S5I
      195.201.148.94 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtDgdBTd8apRMBTweK9ZMRTdFqkU1mbKQDmyXSXbhSQAYwlgkmh1ee4TBE4nt/2b28QT5AqWOazVraqlAoSp+n7GwdsPH26lhbuF+ZVHq05X3RuJLmbhOsa6QlPzjSHiyj+Onkmj9DyXwKhhMErGcT1n2nhC4Oi007qsqcYQIB/YJ7hmMDABMzm9Bwd5Rk6xsDfz+9umvSMpwtfctpKixoVq90Fe3X6wloo5sgXpqfdP1IDFxfiaDp6nOQuOhvcA1Z67oGpW3T8CbZ5aDqA8e1vtpkl7oT3YolR+5153B/e0zOSAk8AabfkLdvrReECg2AHloH7hf9TOBVH0RVZluK+GRVJoaO2b3EspwIlThdQthiZH5/6vwDLsY6zNw6bUlKNntcNbJ5ZHc7zVv03Zlbpp6aWye0O3HR1PkaOo7pragEX9VAGj8Af2fNinSZVtd30gZlRFhLXQRAad+gC9R/5Q9X7V9BZBbWZ3J9DCP5zFoM9Y2R2YySjHX8Dmy7Jps=
      195.201.148.94 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBAFh44c1Efqv/g8lvjDSY6uBYevByf1fg4BhLVcfYudqrSSSwbeaPrv6B+M5psrHo6/zthciDzp4oYUG8ANVRWs=
      [localhost]:49388 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFr1jHueUdsh4Bc9meR1Var4hbZKLCnZGfCSpsP0oOeS
      [localhost]:49388 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHr9ZzEzC+2s1YNfPsFqDMbZv+o4XG2tEWlAF3DzzgdDawwxSj963qR46OqefPO+yiPBR/x3tFjXtSQ96qDcum9fzuiSzB+z5+/Zhs7VWEPi9ugGTDLFpX823EQrgcVKFE4jWnGsx6Ek8C9YojKgKf5afHG+ww2jNhTPHgVTrQkqo0JzUEnfjhJ/1/WluzpiGHfIy9re5MU10f2z9Vja7M0oDZ/Je+zavA4tlQpZ3URQnCEKC2vf7DhtwYBAOuyXKMdUSaTNdeTytmDjxdhJ38q8bwTHtfLUBzyYjW012Q5d1+/g1dqInu99uN/+UjTJc/GFiqLCE0tmco1GafptnKHJLgDC93vE832G5qvxhykfUAJdNW58kbWugeQm6Rb0i1UL5ckVHurMZT9BL6E9LKV0SewozyBtnA21RKu1vsheN86N0uBLwn3v1r0H3xPL4+S1WbmpXpIoCAoyTLc2janw2Gt22W1p08tv+a+lntFVqBn5ZSpcaUxQ6wRQQAfokqDh5YUzb+Tu9Fxi483qb6bd18io3kMLDre3G4xXqlvAB386Uj8iAYivmZIPBEFDCWBVki9LzWPfQGumgYN0CqSM6Gpqk0RnyU1CNPACEGaRpE1ph4Dgl9NQzRCiw/fEUiMZy1CTkly1YCiqSpp2iMmsJw+QJjfAbehEP+Tl8NIQ==
    '';

    programs.ssh = {
      enable = true;
      matchBlocks = {
        "*" = {
          identityFile = "/home/borgs/backups/borgs-private";
        };
        ouranos = {
          hostname = "195.201.148.94";
          user = "root";
        };
        fusus = {
          hostname = "localhost";
          user = "server";
          port = 49388;
        };
        ocih = {
          hostname = "152.67.70.13";
          user = "ubuntu";
        };
      };
    };
  };

  # automatically creates the mountpoint as well!!
  fileSystems."/home/borgs/backups" = {
    device = "/home/files/storage/backups/servers";
    options = [ "bind" ];
  };

  # ouranus
  systemd.services.backup-ouranos-minecraft = {
    enable = true;
    description = "backup the /var/minecraft folder on ouranus to fusu";
    unitConfig = {
      Type = "simple";
    };
    path = with pkgs; [ curl bash socat borgbackup openssh ];
    serviceConfig = {
      ExecStart = "/home/borgs/backups/ouranos-minecraft.sh";
      User = "borgs";
      Group = "borgs";
      WorkingDirectory = "/home/borgs/backups";
      ExecStopPost = "/home/borgs/backups/exit-ouranos-minecraft.sh";
    };
    wants = [ "home-files-storage.mount" ];
  };
  systemd.timers.backup-ouranos-minecraft = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      #OnBootSec = "5m";
      #nUnitActiveSec = "1d";
      OnCalendar = "*-*-* 04:00:00";
      Persistent = "True";
      Unit = "backup-ouranos-minecraft.service";
    };
  };

  # ouranus
  systemd.services.backup-fusu-server = {
    enable = true;
    description = "backup the ~/server folder on fusus";
    unitConfig = {
      Type = "simple";
    };
    path = with pkgs; [ curl bash socat borgbackup openssh ];
    serviceConfig = {
      ExecStart = "/home/borgs/backups/fusu-server.sh";
      User = "borgs";
      Group = "borgs";
      WorkingDirectory = "/home/borgs/backups";
      ExecStopPost = "/home/borgs/backups/exit-fusu-server.sh";
    };
    wants = [ "home-files-storage.mount" ];
  };
  systemd.timers.backup-fusu-server = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      #OnBootSec = "5m";
      #OnUnitActiveSec = "1d";
      OnCalendar = "*-*-* 03:00:00";
      Persistent = "True";
      Unit = "backup-fusu-server.service";
    };
  };

  # ocih
  systemd.services.backup-ocih = {
    enable = true;
    description = "backup the ~/host folder on ocih";
    unitConfig = {
      Type = "simple";
    };
    path = with pkgs; [ curl bash socat borgbackup openssh ];
    serviceConfig = {
      ExecStart = "/home/borgs/backups/ocih.sh";
      User = "borgs";
      Group = "borgs";
      WorkingDirectory = "/home/borgs/backups";
      ExecStopPost = "/home/borgs/backups/exit-ocih.sh";
    };
    wants = [ "home-files-storage.mount" ];
  };
  systemd.timers.backup-ocih = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      #OnBootSec = "5m";
      #OnUnitActiveSec = "1d";
      OnCalendar = "*-*-* 02:00:00";
      Persistent = "True";
      Unit = "backup-ocih.service";
    };
  };


}
