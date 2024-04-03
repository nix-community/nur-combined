{ lib, pkgs, inputs, secretsDir, system, ... }:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    #inputs.nixos-hardware.nixosModules.raspberry-pi-4
    inputs.networkmanager.nixosModules.networkmanager

		../common/all.nix
		../common/nixos-headless.nix
    ../common/nixos.nix

		inputs.home-manager.nixosModules.home-manager
		../users/me/headless.nix
		../users/root/default.nix
    ../users/server/headles.nix
    ../users/files/headless.nix
  ];

  # to cross compile
  #nixpkgs.hostPlatform.system = "aarch64-linux";
  #nixpkgs.buildPlatform.system = "x86_64-linux";

  hardware.enableRedistributableFirmware = true;

  # This causes an overlay which causes a lot of rebuilding
  environment.noXlibs = lib.mkForce false;
  # "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" creates a
  # disk with this label on first boot. Therefore, we need to keep it. It is the
  # only information from the installer image that we need to keep persistent

  environment.systemPackages = with pkgs; [
    bcache-tools
    su
    fuse3
    terraform
  ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

  fileSystems."/home/files/storage" =
    { device = "/dev/bcache0p1";
      fsType = "ext4";
    };

  fileSystems."/svn" = {
		device = "/home/files/storage/files/stuff/svn";
  	options = [ "bind" ];
  };

 swapDevices = [ {
    device = "/swapfile";
    size = 10*1024;
  } ];

  boot = {
    #kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    loader = {
      generic-extlinux-compatible.enable = lib.mkDefault true;
      grub.enable = lib.mkDefault false;
      raspberryPi.firmwareConfig = ''
        program_usb_boot_mode=1
      '';
    };
  };

  virtualisation.podman.enable = true;


  users.users.mamafiles = {
   	isNormalUser = true;
		password = "changeme";
  };

########################## networking ###########################################

	networking.firewall.allowPing = true;
	networking.firewall.enable = true;
	services.samba.openFirewall = true;

  networking.hostName = "rpi";

	networking.firewall.allowedTCPPorts = [
  	5357 # wsdd
		8888 # for general usage
		9999 # for general usage
    8080 # for mitm proxy

    49388
    49389
    49390
    49391
    49392
    49393
	];

	networking.firewall.allowedUDPPorts = [
  		3702 # wsdd
	];


  networking.networkmanager.enable = true;

  networking.networkmanager.profiles = {
    main = {
      connection = {
        id = "main";
        uuid = "a02273d9-ad12-395e-8372-f61129635b6f";
        type = "ethernet";
        autoconnect-priority = "-999";
        interface-name = "end0";
      };
      ipv4 = {
        address1 = "192.168.1.2/24,192.168.1.1";
        dns = "1.1.1.1;";
        method = "manual";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = builtins.readFile "${secretsDir}/wifi-rpi-password";
      };
    };

    hot = {
      connection = {
        id = "hot";
        uuid = "ab51de8a-9742-465a-928b-be54a83ab6a3";
        type = "wifi";
        autoconnect = "false";
        interface-name = "wlan0";
      };
      wifi = {
        mac-address = "0C:96:E6:E3:64:03";
        mode = "ap";
        ssid = "c2vi-rpi";
      };

      ipv4 = {
        method = "shared";
      };
    };

  /*
    me = {
     connection = {
        id = "me";
        uuid = "fe45d3bc-21c6-41ff-bc06-c936017c6e02";
        type = "wireguard";
        autoconnect = "true";
        interface-name = "me0";
     };
      wireguard = {
        listen-port = "49390";
        private-key = builtins.readFile "${secretsDir}/wg-private-rpi";
      };
      ipv4 = {
        address1 = "10.1.1.2/24";
        method = "manual";
      };
    } // (import ../common/wg-peers.nix { inherit secretsDir; }) ;
  */
  };

  ######################################### wstunnel #######################################

  systemd.services.wstunnel = {
    enable = true;
    description = "WStunnel for SSH connections and Wireguard VPN";
    after = [ "network.target" ];
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.wstunnel}/bin/wstunnel --server ws://0.0.0.0:49389 -r 127.0.0.1:49388 -r 127.0.0.1:49390";
    };
    wantedBy = [ "multi-user.target" ];
  };

  ###################################### dyndns ####################################

  systemd.services.update-ip = 
    let 
    update-ip = pkgs.writeShellApplication {
      name = "update-ip";

      runtimeInputs = with pkgs; [ curl w3m ];

      text = ''
        ip=$(curl my.ip.fi)
        curl "http://dynv6.com/api/update?hostname=${builtins.readFile "${secretsDir}/dns-name-two"}&ipv4=$ip&token=${builtins.readFile "${secretsDir}/dns-name-two-token"}"
        curl "https://dynamicdns.park-your-domain.com/update?host=@&domain=${builtins.readFile "${secretsDir}/dns-name"}&password=${builtins.readFile "${secretsDir}/dns-name-token"}&ip=$ip"

        # https://www.namecheap.com/support/knowledgebase/article.aspx/29/11/how-to-dynamically-update-the-hosts-ip-with-an-https-request/
      '';
      };
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


  ################################## ssh ######################################
  services.openssh = {
    enable = true;
    ports = [ 49388 ];

    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  	settings.PermitRootLogin = "no";
    settings.X11Forwarding = true;
    extraConfig = ''
      X11UseLocalhost no
    '';
  };

	################################ samba ######################################
	services.samba-wsdd.enable = true; # make shares visible for windows 10 clients

	services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      server role = standalone server
      map to guest = bad user
      usershare allow guests = yes
      hosts allow = 192.168.0.0/16
      hosts deny = 0.0.0.0
      workgroup = WORKGROUP
      security = user
    '';
    shares = {
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
        "recycle:keeptree" = "No";
        "recycle:versions" = "Yes";
        "recycle:touch" = "Yes";
        "recycle:touch_mtime" = "Yes";
        "recycle:maxsize" = "8000";
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

  ############################## files backup ##################################
  # needs that
  programs.fuse.userAllowOther = true; # otherwise the root user has no acces to the mount
  systemd.services.rclone-mount-backup = {
    enable = true;
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


	################################ server ######################################
  /*
  systemd.services.nginx-pod = {
    enable = true;
    description = "pod for nginx proxy manager";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      ExecStart = let prg = pkgs.writeShellApplication {
        name = "nginx-pod";
        runtimeInputs = with pkgs; [ su shadow ];
        text = lib.strings.concatStringsSep " " [
          "${inputs.podman.packages.${system}.podman}/bin/podman" "pod" "create"
          "--name=nginx"
          "--share net"
          "-p 81:81"
          "-p 80:80"
          "-p 443:443"
        ];
      }; in "${prg}/bin/nginx-pod";
      User = "server";
      Group = "server";
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.nginx-db = {
    enable = true;
    description = "bar";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      ExecStart = let prg = pkgs.writeShellApplication {
        name = "nginx-db";
        runtimeInputs = with pkgs; [ su shadow ];
        text = lib.strings.concatStringsSep " " [
          # make data dir if non existent
          "${pkgs.coreutils}/bin/mkdir -p /home/server/here/nginx/data;"

          "${inputs.podman.packages.${system}.podman}/bin/podman" "container" "run"
          "--name=nginx_db"
          "--pod=nginx"
          "-e MYSQL_ROOT_PASSWORD=HAg!HZiZQ9ydGlFK7KP4"
          "-e MYSQL_DATABASE=nginx-proxy-manager"
          "-e MYSQL_USER=webserver"
          ''"-e MYSQL_PASSWORD=n1jK69EQEBOiJ&YPmbeW"''
          "-v /home/server/here/nginx/data/mysql:/var/lib/mysql:Z"
          "--add-host app:127.0.0.1"
          "--add-host nginx_app:127.0.0.1"
          "--add-host db:127.0.0.1"
          "--add-host nginx_db:127.0.0.1"
          "--restart unless-stopped"

          # last image name
          "nginx-proxy-manager"
        ];
      }; in "${prg}/bin/nginx-db";
      User = "server";
      Group = "server";
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.nginx = {
    enable = true;
    description = "bar";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      ExecStart = let prg = pkgs.writeShellApplication {
        name = "nginx";
        runtimeInputs = with pkgs; [ su shadow ];
        text = lib.strings.concatStringsSep " " [
          # make data dir if non existent
          "${pkgs.coreutils}/bin/mkdir -p /home/server/here/nginx/data;"

          "${inputs.podman.packages.${system}.podman}/bin/podman" "container" "run"
          "--name=nginx_app"
          "--pod=nginx"

          "-e DB_MYSQL_HOST=db"
          "-e DB_MYSQL_PORT=3306"
          "-e DB_MYSQL_USER=webserver"
          ''"e DB_MYSQL_PASSWORD=n1jK69EQEBOiJ&YPmbeW"''
          "-e DB_MYSQL_NAME=nginx-proxy-manager"
          "-v /home/server/here/nginx/data:/data"
          "-v /home/server/here/nginx/data/letsencrypt:/etc/letsencrypt"
          "--add-host app:127.0.0.1"
          "--add-host nginx_app:127.0.0.1"
          "--add-host db:127.0.0.1"
          "--add-host nginx_db:127.0.0.1"

          "--restart unless-stopped"

          # last image name
          "mariadb-aria"
        ];
      }; in "${prg}/bin/nginx";
      User = "server";
      Group = "users";
    };
    wantedBy = [ "multi-user.target" ];
  };

*/
}
