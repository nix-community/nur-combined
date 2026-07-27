{ pkgs, lib, ... }:

with lib;
let
  hostname = "kerkouane";
  metadata = importTOML ../../ops/hosts.toml;

  secretPath = ../../secrets/machines.nix;
  secretCondition = (builtins.pathExists secretPath);

  isAuthorized = p: builtins.isAttrs p && p.authorized or false;
  authorizedKeys = lists.optionals secretCondition (
    attrsets.mapAttrsToList
      (name: value: value.key)
      (attrsets.filterAttrs (name: value: isAuthorized value) (import secretPath).ssh)
  );

  wireguardIp = strings.optionalString secretCondition (import secretPath).wireguard.ips."${hostname}";

  nginxExtraConfig = ''
    expires 31d;
    add_header Cache-Control "public, max-age=604800, immutable";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
    add_header X-Content-Type-Options "nosniff";
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Security-Policy "default-src 'self' *.sbr.pm *.sbr.systems *.demeester.fr";
    add_header X-XSS-Protection "1; mode=block";
  '';

  nginx = pkgs.nginxMainline.override (old: {
    modules = with pkgs.nginxModules; [
      fancyindex
    ];
  });

  filesWWW = {
    enableACME = true;
    forceSSL = true;
    root = "/var/www/dl.sbr.pm";
    locations."/" = {
      index = "index.html";
      extraConfig = ''
        fancyindex on;
        fancyindex_localtime on;
        fancyindex_exact_size off;
        fancyindex_header "/.fancyindex/header.html";
        fancyindex_footer "/.fancyindex/footer.html";
        # fancyindex_ignore "examplefile.html";
        fancyindex_ignore "README.md";
        fancyindex_ignore "HEADER.md";
        fancyindex_ignore ".fancyindex";
        fancyindex_name_length 255;
      '';
    };
    locations."/private" = {
      extraConfig = ''
        auth_basic "Restricted";
        auth_basic_user_file /var/www/dl.sbr.pm/private/.htpasswd;
      '';
    };
    extraConfig = nginxExtraConfig;
  };

  sources = import ../../nix/sources.nix;
in
{
  imports = [
    (import ../../users/vincent)
    (import ../../users/root)
  ];

  networking.hostName = hostname;

  ## From qemu-quest.nix
  boot.initrd.availableKernelModules = [ "virtio_net" "virtio_pci" "virtio_mmio" "virtio_blk" "virtio_scsi" "9p" "9pnet_virtio" ];
  boot.initrd.kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" ];

  boot.initrd.postDeviceCommands =
    ''
      # Set the system time from the hardware clock to work around a
      # bug in qemu-kvm > 1.5.2 (where the VM clock is initialised
      # to the *boot time* of the host).
      hwclock -s
    '';

  # START OF DigitalOcean specifics
  # FIXME: move this into a secret ?
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [
      "67.207.67.2"
      "67.207.67.3"
    ];
    defaultGateway = "188.166.64.1";
    defaultGateway6 = "";
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce true;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address = "188.166.102.243"; prefixLength = 18; }
          { address = "10.18.0.5"; prefixLength = 16; }
        ];
        ipv6.addresses = [
          { address = "fe80::8035:3aff:fe72:1036"; prefixLength = 64; }
        ];
      };

    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="82:35:3a:72:10:36", NAME="eth0"

  '';
  # END OF DigitalOcean specifics

  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.enable = lib.mkForce true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  fileSystems."/" = { device = "/dev/vda1"; fsType = "ext4"; };
  swapDevices = [{ device = "/swapfile"; size = 1024; }];

  core.nix = {
    # FIXME move this away
    localCaches = [ ];
    buildCores = 1;
  };

  modules.services = {
    wireguard.server.enable = true;
    syncthing = {
      enable = true;
      guiAddress = "${metadata.hosts.kerkouane.wireguard.addrs.v4}:8384";
    };
    ssh = {
      enable = true;
      extraConfig = ''
	Match User nginx
        ChrootDirectory /var/www
        ForceCommand interfal-sftp
        AllowTcpForwarding no
        PermitTunnel no
        X11Forwarding no
      '';
    };
  };

  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  security = {
    acme = {
      acceptTerms = true;
      email = "vincent@sbr.pm";
    };
    #acme.certs = {
    #  "sbr.pm".email = "vincent@sbr.pm";
    #};
  };
  security.pam.enableSSHAgentAuth = true;
  #systemd.services.nginx.serviceConfig.ReadWritePaths = [ "/var/www" ];
  services = {
    prometheus.exporters = {
      node = {
	enable = true;
	port = 9000;
	enabledCollectors = [ "systemd" "processes" ];
	extraFlags = ["--collector.ethtool" "--collector.softirqs" "--collector.tcpstat"];
      };
      nginx = {
	enable = true;
	port = 9001;
      };
      # wireguard = { enable = true; };
    };
    gosmee = {
      enable = true;
      public-url = "https://webhook.sbr.pm";
    };
    govanityurl = {
      enable = true;
      user = "nginx";
      host = "go.sbr.pm";
      config = ''
        paths:
          /lord:
            repo: https://github.com/vdemeester/lord
          /ape:
            repo: https://git.sr.ht/~vdemeester/ape
          /nr:
            repo: https://git.sr.ht/~vdemeester/nr
          /ram:
            repo: https://git.sr.ht/~vdemeester/ram
          /sec:
            repo: https://git.sr.ht/~vdemeester/sec
      '';
    };
    nginx = {
      enable = true;
      statusPage = true;
      package = nginx;
      recommendedGzipSettings = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      virtualHosts."dl.sbr.pm" = filesWWW;
      virtualHosts."files.sbr.pm" = filesWWW;
      virtualHosts."paste.sbr.pm" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/paste.sbr.pm";
        locations."/" = {
          index = "index.html";
        };
        extraConfig = nginxExtraConfig;
      };
      virtualHosts."go.sbr.pm" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = { proxyPass = "http://127.0.0.1:8080"; };
        extraConfig = nginxExtraConfig;
      };
      virtualHosts."whoami.sbr.pm" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://10.100.0.8:80";
          extraConfig = ''
            proxy_set_header Host            $host;
            proxy_set_header X-Forwarded-For $remote_addr;
          '';
        };
      };
      virtualHosts."webhook.sbr.pm" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3333";
          extraConfig = ''
            proxy_buffering off;
            proxy_cache off;
            proxy_set_header Host            $host;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header Connection "";
            proxy_http_version 1.1;
            chunked_transfer_encoding off;
          '';
        };
      };
      virtualHosts."sbr.pm" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/sbr.pm";
        locations."/" = {
          index = "index.html";
        };
        extraConfig = nginxExtraConfig;
      };
      virtualHosts."sbr.systems" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/sbr.systems";
        locations."/" = {
          index = "index.html";
        };
        extraConfig = nginxExtraConfig;
      };
      virtualHosts."vincent.demeester.fr" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/vincent.demeester.fr";
        locations."/" = {
          index = "index.html";
          extraConfig = ''
            default_type text/html;
            try_files $uri $uri.html $uri/ = 404;
            fancyindex on;
            fancyindex_localtime on;
            fancyindex_exact_size off;
            fancyindex_header "/assets/.fancyindex/header.html";
            fancyindex_footer "/assets/.fancyindex/footer.html";
            # fancyindex_ignore "examplefile.html";
            fancyindex_ignore "README.md";
            fancyindex_ignore "HEADER.md";
            fancyindex_ignore ".fancyindex";
            fancyindex_name_length 255;
          '';
        };
        extraConfig = nginxExtraConfig;
      };
    };
    openssh = {
      listenAddresses = [
        { addr = wireguardIp; port = 22; }
      ];
      openFirewall = false;
      passwordAuthentication = false;
      permitRootLogin = "without-password";
    };
  };
}

