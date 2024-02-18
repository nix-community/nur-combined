{ pkgs
, lib
, config
, self
, ...
}:

{
  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # xdgOpenUsePortal = true;
  };


  services = {
    bpftune.enable = true;
    kubo = {
      enable = false;
      settings.Addresses.API = [
        "/ip4/127.0.0.1/tcp/5001"
      ];
    };
    hysteria.instances = [
    ];
    i2pd = {
      enable = true;
      notransit = true;
      outTunnels = {
        # ssh-vpqn = {
        #   enable = true;
        #   name = "ssh";
        #   destination = "";
        #   address = "127.0.0.1";
        #   port = 2222;
        # };
      };
    };

    btrbk = {
      config = ''
        ssh_identity /persist/keys/ssh_host_ed25519_key
        timestamp_format        long
        snapshot_preserve_min   48h
        snapshot_preserve       168h 
        volume /persist
          snapshot_dir .snapshots
          subvolume .
          snapshot_create onchange
        volume /var
          snapshot_dir .snapshots
          subvolume .
          snapshot_create onchange
      '';
    };
    fwupd.enable = true;
    # vault = { enable = true; extraConfig = "ui = true"; package = pkgs.vault-bin; };



    dbus = {
      enable = true;
      implementation = "broker";
      apparmor = "enabled";
    };


    # github-runners = {
    #   runner1 = {
    #     enable = false;
    #     name = "nixos-0";
    #     tokenFile = config.age.secrets.gh-eu.path;
    #     url = "https://github.com/oluceps/eunomia-bpf";
    #   };
    # };
    # autossh.sessions = [
    #   {
    #     extraArguments = "-NTR 5002:127.0.0.1:22 az";
    #     monitoringPort = 20000;
    #     name = "az";
    #     inherit user;
    #   }
    # ];
    flatpak.enable = true;
    journald.extraConfig =
      ''
        SystemMaxUse=1G
      '';
    # sundial = {
    #   enable = false;
    #   calendars = [ "Sun,Mon-Thu 23:18:00" "Fri,Sat 23:48:00" ];
    #   warnAt = [ "Sun,Mon-Thu 23:16:00" "Fri,Sat 23:46:00" ];
    # };

    # HORRIBLE
    # mongodb = {
    #   enable = false;
    #   package = pkgs.mongodb-6_0;
    #   enableAuth = true;
    #   initialRootPassword = "initial";
    # };

    # ????
    udev = {

      packages = with pkgs;[
        android-udev-rules
        # qmk-udev-rules
        jlink-udev-rules
        yubikey-personalization
        libu2f-host
        via
        opensk-udev-rules
        nrf-udev-rules
      ];
    };

    gnome.gnome-keyring.enable = true;

    # hyst-az.enable = false;
    # hyst-do.enable = false;

    # ss-tls cnt to router

    clash =
      {
        enable =
          false;
      };

    rathole.enable = false;

    daed.enable = false;
    dae = {
      disableTxChecksumIpGeneric = false;
      configFile = config.age.secrets.dae.path;
      # assets = with pkgs; [ v2ray-geoip v2ray-domain-list-community ];
      # package = pkgs.dae-unstable;
      assetsPath = "${pkgs.symlinkJoin {
        name = "dae-assets-nixy";
        paths = [ pkgs.nixy-domains.src "${pkgs.v2ray-geoip}/share/v2ray" ];
      }}";

      openFirewall = {
        enable = true;
        port = 12345;
      };
    };

    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [ "/persist" ];
    };
    pcscd.enable = true;

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = lib.mkForce false;
        PermitRootLogin = lib.mkForce "prohibit-password";
        UseDns = false;
        X11Forwarding = false;
      };
      authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];
      extraConfig = ''
        ClientAliveInterval 60
        ClientAliveCountMax 720
      '';
    };

    fail2ban = {
      enable = true;
      maxretry = 5;
      ignoreIP = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
      ];
    };

    mosdns = {
      config = {
        log = { level = "debug"; production = false; };
        plugins = let src = "${pkgs.nixy-domains.src}"; in [
          {
            args = {
              files = [ "${src}/accelerated-domains.china.txt" ];
            };
            tag = "direct_domain";
            type = "domain_set";
          }
          {
            args = {
              files = [ "${src}/all_cn.txt" ];
            };
            tag = "direct_ip";
            type = "ip_set";
          }
          {
            args = {
              dump_file = "./cache.dump";
              lazy_cache_ttl = 86400;
              size = 65536;
              dump_interval = 600;
            };
            tag = "cache";
            type = "cache";
          }
          {
            args = {
              concurrent = 2;
              upstreams = [
                {
                  addr = "https://1.0.0.1/dns-query";
                }
                {
                  addr = "tls://8.8.4.4:853";
                  enable_pipeline = true;
                }
              ];
            };
            tag = "remote_forward";
            type = "forward";
          }
          {
            args = {
              concurrent = 2;
              upstreams = [
                {
                  addr = "quic://dns.alidns.com";
                  dial_addr = "223.6.6.6";
                }
                {
                  addr = "tls://dot.pub";
                  dial_addr = "1.12.12.12";
                  enable_pipeline = true;
                }
              ];
            };
            tag = "local_forward";
            type = "forward";
          }
          {
            args = {
              concurrent = 2;
              upstreams = [
                {
                  addr = "udp://192.168.1.1";
                }
              ];
            };
            tag = "local_domain_forward";
            type = "forward";
          }
          {
            args = [
              { exec = "ttl 600-3600"; }
              { exec = "accept"; }
            ];
            tag = "ttl_sequence";
            type = "sequence";
          }
          {
            args = [
              { exec = "query_summary local_forward"; }
              { exec = "$local_forward"; }
              { exec = "goto ttl_sequence"; }
            ];
            tag = "local_sequence";
            type = "sequence";
          }
          {
            args = [
              { exec = "query_summary local_area"; }
              { exec = "$local_domain_forward"; }
              { exec = "goto ttl_sequence"; }
            ];
            tag = "local_area";
            type = "sequence";
          }
          {
            args = [
              { exec = "query_summary remote_forward"; }
              { exec = "$remote_forward"; }
              { exec = "goto local_sequence"; matches = "resp_ip $direct_ip"; }
              { exec = "goto ttl_sequence"; }
            ];
            tag = "remote_sequence";
            type = "sequence";
          }
          {
            args = {
              always_standby = false;
              primary = "remote_sequence";
              secondary = "local_sequence";
              threshold = 500;
            };
            tag = "final";
            type = "fallback";
          }
          {
            args = [
              # { exec = "prefer_ipv4"; }
              { exec = "$cache"; }
              { exec = "accept"; matches = "has_resp"; }
              {
                exec = "$local_domain_forward";
                matches =
                  "qname ${with builtins; (concatStringsSep " " (map (n: "full:" + n + ".") (attrNames self.nixosConfigurations)))}";
              }
              { exec = "accept"; matches = "has_resp"; }
              { exec = "goto local_sequence"; matches = "qname $direct_domain"; }
              { exec = "$final"; }
            ];
            tag = "main_sequence";
            type = "sequence";
          }
          {
            args = {
              entry = "main_sequence";
              listen = ":53";
            };
            tag = "udp_server";
            type = "udp_server";
          }
          {
            args = {
              entry = "main_sequence";
              listen = ":53";
            };
            tag = "tcp_server";
            type = "tcp_server";
          }
          {
            tag = "quic_server";
            type = "quic_server";
            args = {
              entry = "main_sequence";
              listen = "127.0.0.1:853";
              cert = config.age.secrets."nyaw.cert".path;
              key = config.age.secrets."nyaw.key".path;
              idle_timeout = 30;
            };
          }
        ];
      };
    };
  };

  programs = {
    ssh.startAgent = false;
    proxychains = {
      enable = true;
      package = pkgs.proxychains-ng;

      chain = {
        type = "strict";
      };
      proxies = {
        socks-hyst-az = {
          enable = false;
          type = "socks5";
          host = "127.0.0.1";
          port = 1083;
        };
        socks-hyst-do = {
          enable = true;
          type = "socks5";
          host = "127.0.0.1";
          port = 1085;
        };
      };
    };
  };
}
