
{ pkgs, lib, workDir, self, secretsDir, config, inputs, ... }:
{

  # https://bugzilla.kernel.org/show_bug.cgi?id=110941
  # ??????????? TODO
  # boot.kernelParams = [ "intel_pstate=no_hwp" ];

  # Supposedly better for the SSD.
  # ??????????? TODO
  # fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  services.nscd.enable = lib.mkForce false;
  system.nssModules = lib.mkForce [];

  # disable touch clicks because i always tap while typing
  #services.xserver.libinput.touchpad.tappingButtonMap = null;
  services.xserver.libinput.touchpad.tapping = false;


	imports = [
		../common/all.nix
		../common/nixos-headless.nix
		../common/nixos-graphical.nix
    ../common/building.nix

    inputs.networkmanager.nixosModules.networkmanager
		inputs.home-manager.nixosModules.home-manager
		../users/me/gui.nix
		../users/root/default.nix

    # see: https://github.com/NixOS/nixpkgs/issues/300081
    #"${inputs.nixpkgs-unstable}/nixos/modules/virtualisation/incus.nix" 
	];


  environment.systemPackages = with pkgs; [
    cifs-utils
    nfs-utils
    ntfs3g
    dhcpcd
    looking-glass-client
    swtpm
    win-virtio
  ];

  # shedule nix builds with low priority, so the laptop is still usable while building something
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIONiceLevel = 7;
  systemd.services.nix-daemon.serviceConfig.Nice = 9;

  # enable ntp
  #services.ntp.enable = true;
  # if i hibernate and ren unhibernate in the school network ... the time will be off, because 0.nixos.pool.ntp.org can't be reached
  services.timesyncd.enable = true;

  ################################### optimisations ####################################
  #boot.kernelPackages = pkgs.linuxPackages; # .overrideAttrs (old: {
    #NIX_CFLAGS_COMPILE = [ (old.NIX_CFLAGS_COMPILE or "") ] ++ [ "-O3" "-march=native" ];
  /*
  #});
  boot.kernelPackages = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor (pkgs.linux_6_1.overrideAttrs (old: {
    NIX_CFLAGS_COMPILE = [ (old.NIX_CFLAGS_COMPILE or "") ] ++ [ "-O3" "-march=native" ];
  })));
  */
  #boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_1.override {
    #argsOverride = rec {
      #NIX_CFLAGS_COMPILE = [ "-O3" "-march=native" ];
    #};
  #});
  #*/
#(old: {
  #}));

  /*
  nixpkgs.overlays = [
    (final: prev: {
      optimizeWithFlags = pkg: flags:
        pkg.overrideAttrs (old: {
          NIX_CFLAGS_COMPILE = [ (old.NIX_CFLAGS_COMPILE or "") ] ++ flags;
        });

      optimizeForThisHost = pkg:
        final.optimizeWithFlags pkg [ "-O3" "-march=native" "-fPIC" ];

      firefox = final.optimizeForThisHost prev.firefox;
    })
  ];
  */


  hardware.bluetooth.settings = {
    General = {
      MultiProfile = "multiple";
    };
  };

   nix = {
      distributedBuilds = false; # false, because i can't build on hpm currently ... not signed by trusted user error
   };

  # to build rpi images
  boot.binfmt.emulatedSystems = [ 
    "aarch64-linux"
  ];

	# some bind mounts
  /*
	fileSystems."${workDir}/priv-share/things" = {
		device = "${workDir}/things";
  		options = [ "bind" ];
	};
	fileSystems."${workDir}/things/htl" = {
		device = "${workDir}/htl";
  		options = [ "bind" ];
	};
	fileSystems."${workDir}/things/diplomarbeit" = {
		device = "${workDir}/diplomarbeit";
  		options = [ "bind" ];
	};
  # */

    # */
  	system.activationScripts.makeBinBash = lib.stringAfter [ "var" ] ''
		# there is no /bin/bash
		# https://discourse.nixos.org/t/add-bin-bash-to-avoid-unnecessary-pain/5673
		ln -nsf /run/current-system/sw/bin/bash /bin/bash
   '';
   # */

  ################################ my youtube blocking service #############################
  environment.etc."host.conf" = {
    # needed so that firefox does not ignore the hosts file
    text = ''
      multi off
      order hosts,nis,bind
    '';
  };
  systemd.services.stark = 
    let 
    stark = pkgs.writeShellApplication {
      name = "stark";

      runtimeInputs = with pkgs; [ curl w3m ];

      text = ''
        if [ -f "/etc/hosts-youtube-block" ];
        then
          timeout=$(cat /etc/hosts-youtube-block)

          # check our daily limit
          if [ -f "/etc/hosts-youtube-daily" ];
          then
          echo hi
          #today=$(cat /etc/hosts-youtube-daily)

          # set timeout to 0 when dayli limit is over 90m
          # and also write 
          fi

          echo "read timeout $timeout"
          if [[ "$timeout" == "1" ]] || [[ "$timeout" == "1\n" ]] || [[ "$timeout" == "-1" ]] || [[ "$timeout" == "0" ]]
          then
            rm -rf /etc/hosts-youtube-block
          else
            timeout=$((timeout - 1))
            echo -en $timeout > /etc/hosts-youtube-block
            echo "new timeout: $timeout"
          fi
        else
          echo "updateing hosts file"
          rm -rf /etc/hosts
          cat ${self}/misc/my-hosts > /etc/hosts
          cat /etc/current_hosts >> /etc/hosts
          #cat ${self}/misc/my-hosts-"$(cat /etc/current_hosts)" >> /etc/hosts
        fi
      '';
      };
    in
  {
    enable = true;
    description = "block Youtube";
    #type = "simple";
    #unitConfig = {
      #Type = "simple";
    #};
    serviceConfig = {
      Restart = "always";
      RestartSec = "60s";
      ExecStart = "${stark}/bin/stark";
    };
    wantedBy = [ "multi-user.target" ];
  };


  ############################## networking ###############################################

	networking.hostName = "main";

	security.polkit.enable = true;
  services.rpcbind.enable = true;

  services.avahi.enable = true;
  services.avahi.hostName = "c2vi";

  networking.networkmanager.enable = true;
  #networking.networkmanager.extraConfig = ''
  #[main]
  #dhcp=dhcpcd
  #'';
  #networking.useDHCP = lib.mkForce true;

	networking.firewall.allowPing = true;
	networking.firewall.enable = true;

	services.samba.openFirewall = true;

	networking.firewall.allowedTCPPorts = [
  	5357 # wsdd
		8888 # for general usage
		9999 # for general usage
    8080 # for mitm proxy
    51820  # wireguard
	];

	networking.firewall.allowedUDPPorts = [
  		3702 # wsdd
      51820  # wireguard
      67 # allow DHCP traffic
      53 # allow dns
	];

  networking.search = [ "c2vi.local" ];
  #networking.hosts = {
    #"10.1.1.3" = [ "phone" ];
  #};
  #environment.etc.hosts.mode = "rw";

  networking.networkmanager.profiles = {
    home = {
      connection = {
        id = "home";
        uuid = "a02273d9-ad12-395e-8372-f61129635b6f";
        type = "ethernet";
        autoconnect-priority = "-999";
        interface-name = "enp1s0";
      };
      ipv4 = {
        address1 = "192.168.1.11/24,192.168.1.1";
        dns = "1.1.1.1;";
        method = "manual";
      };
    };

    htl = {
      connection = {
        id = "htl";
        uuid = "0d3af539-9abd-4417-b882-cbff96fc3490";
        type = "wifi";
        interface-name = "wlo1";
      };
      ipv4 = {
        method = "auto";
      };
      wifi = {
        mode = "infrastructure";
        ssid = "HTLinn";
      };
      wifi-security = {
        key-mgmt = "wpa-eap";
        auth-alg = "open";
      };
      "802-1x" = {
        eap = "peap";
        identity = builtins.readFile "${secretsDir}/school-username";
        password = builtins.readFile "${secretsDir}/school-password";
        phase2-auth = "mschapv2";
      };
    };

    pt = {
      connection = {
        id = "pt";
        uuid = "f028117e-9eef-47c1-8483-574f7ee798a4";
        type = "bluetooth";
        autoconnect = "false";
      };

      bluetooth = {
        bdaddr = "E8:78:29:C4:BA:7C";
        type = "panu";
      };

      ipv4 = {
        address1 = "192.168.44.11/24";
        method = "auto";
      };
    };

    pw = {
      connection = {
        id = "pw";
        uuid = "e0103dac-7da0-4e32-a01b-487b8c4c813c";
        type = "wifi";
        interface-name = "wlo1";
      };

      wifi = {
        hidden = "true";
        mode = "infrastructure";
        ssid = builtins.readFile "${secretsDir}/wifi-ssid";
      };

      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = builtins.readFile "${secretsDir}/wifi-password";
      };

      ipv4 = {
        #address1 = "192.168.20.11/24";
        dns = "1.1.1.1;8.8.8.8;";
        method = "auto";
      };
    };

    hec = {
      connection = {
        id = "hec";
        uuid = "a84fdbd8-af9c-4e2d-9185-7676e9d139f4";
        type = "wifi";
        interface-name = "wlo1";
      };

      wifi = {
        hidden = "true";
        mode = "infrastructure";
        ssid = builtins.readFile "${secretsDir}/hec-wifi-ssid";
      };

      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = builtins.readFile "${secretsDir}/hec-wifi-password";
      };

      ipv4 = {
        #address1 = "192.168.20.11/24";
        method = "auto";
      };
    };

    hot = {
      connection = {
        id = "hot";
        uuid = "ab51de8a-9742-465a-928b-be54a83ab6a3";
        type = "wifi";
        autoconnect = false;
        interface-name = "wlo1";
      };
      wifi = {
        mac-address = "0C:96:E6:E3:64:03";
        mode = "ap";
        ssid = "c2vi-main";
      };

      ipv4 = {
        method = "shared";
      };
    };

    share = {
      connection = {
        id = "share";
        uuid = "f55f34e3-4595-4642-b1f6-df3185bc0a04";
        type = "ethernet";
        autoconnect = false;
        interface-name = "enp1s0";
      };

      ethernet = {
        mac-address = "F4:39:09:4A:DF:0E";
      };

      ipv4 = {
        address1 = "192.168.4.1/24";
        method = "shared";
      };

      ipv6 = {
        addr-gen-mode = "stable-privacy";
        method = "auto";
      };
    };

    dhcp = {
      connection = {
        id = "dhcp";
        uuid = "c006389a-1697-4f77-91c3-95b466f85f13";
        type = "ethernet";
        autoconnect = "false";
        interface-name = "enp1s0";
      };

      ethernet = {
        mac-address = "F4:39:09:4A:DF:0E";
      };

      ipv4 = {
        method = "auto";
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
        listen-port = "51820";
        private-key = builtins.readFile "${secretsDir}/wg-private-main";
      };
      ipv4 = {
        address1 = "10.1.1.11/24";
        method = "manual";
      };
    } // (import ../common/wg-peers.nix { inherit secretsDir; });
    */
  };

  /*
  networking.wireguard.interfaces = {
    me1 = {
      ips = [ "10.1.1.11/24" ];
      listenPort = 51820;

      privateKeyFile = "${secretsDir}/wg-private-main";

      peers = import ../common/wg-peers.nix { inherit secretsDir; };
    };
  };
  # */



	#################################### samba ######################################
	services.samba-wsdd.enable = true; # make shares visible for windows 10 clients

	services.samba = {
  		enable = true;
  		securityType = "user";
  		extraConfig = ''
			security = user
			map to guest = bad user
			guest account = me

			server role = standalone server
			workgroup = WORKGROUP
  		'';
  		shares = {
    		rpi_schule = {
    			path = "${workDir}/rpi-schule/";
	 			"guest ok" = "yes";
    			"read only" = "no";
    			public = "yes";
    			writable = "yes";
    			printable = "no";
    			comment = "share for rpi in school wlan";
    		};

    		share = {
    			comment = "share for sharing stuff";
    			path = "${workDir}/share";
    			public = "yes";
	 			"guest ok" = "yes";
    			"read only" = "no";
    			writable = "yes";
    		};
  		};
	};


  ######################################### virtualisation ###############################
  	virtualisation.libvirtd = {
      enable = true;
      qemuOvmf = true;
      qemuSwtpm = true;
      #qemuOvmfPackage = pkgs.OVMFFull;
    };


    # see: https://github.com/NixOS/nixpkgs/issues/300081
    #disabledModules = [ "virtualisation/incus.nix" ]; 
    networking.nftables.enable = true;
    # client package now separated...
    #virtualisation.incus.clientPackage = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.incus;
    virtualisation.incus.enable = true;
    systemd.services.incus.path = [ pkgs.swtpm ];
    #virtualisation.incus.package = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.incus;
    users.users.me.extraGroups = [ "incus-admin" ];


    virtualisation.podman.enable = true;

    virtualisation.kvmgt.enable = true;
    boot.extraModprobeConfig = "options i915 enable_guc=2";
    boot.kernelParams = [ "intel_iommu=on" "pcie_aspm=force" ];

    virtualisation.kvmgt.vgpus = {
      "i915-GVTg_V5_8" = {
        uuid = [ "1382e8c5-b033-481b-99b8-e553ef6a0056" ];
      };
    };

     /*
  	system.activationScripts.setupLibvirt = lib.stringAfter [ "var" ] ''
      mkdir -p /var/lib/libvirt/storage
      ln -nsf ${workDir}/vm/libvirt/my-image-pool.xml /var/lib/libvirt/storage/my-image-pool.xml
      rm -rf /var/lib/libvirt/qemu/networks
      ls ${workDir}/vm/qemu | while read path
      do
        ln -nsf ${workDir}/vm/qemu/$path /var/lib/libvirt/qemu/$path
      done
    '';
    # */



	############################## swap and hibernate ###################################
	swapDevices = [ { device = "/dev/lvm0/swap"; } ];
	boot.resumeDevice = "/dev/lvm0/swap";
	services.logind = {
		extraConfig = ''
			HandlePowerKey=suspend-then-hibernate
		'';
		lidSwitch = "suspend-then-hibernate";
		lidSwitchExternalPower = "suspend-then-hibernate";
		lidSwitchDocked = "ignore";
	};
	systemd.sleep.extraConfig = ''
		HibernateDelaySec=2h
		HibernateMode=shutdown
	'';
}


