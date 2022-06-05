imports: { config, lib, pkgs, ... }:

with lib;

let
  ip4 = pkgs.nur.repos.dukzcry.lib.ip4;
  cfg = config.services.rkn;
  tor = cfg.transports.tor;
  serviceOptions = {
    LockPersonality = true;
    PrivateDevices = true;
    PrivateIPC = true;
    PrivateMounts = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK";
    RestrictNamespaces = true;
    RestrictRealtime = true;
    MemoryDenyWriteExecute = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = "~@clock @cpu-emulation @debug @keyring @module @mount @obsolete @raw-io @resources";
    DynamicUser = true;
    StateDirectory = "rkn-script";
  };
  nginx = name: value: {
    services.nginx.enable = true;
    services.nginx.proxyResolveWhileRunning = true;
    services.nginx.resolver = {
      addresses = [ cfg.resolver ];
      ipv6 = !cfg.ipv4Only;
    };
    services.nginx.virtualHosts = {
      "${name}" = {
        default = true;
        listen = [{ addr = value.address.address; port = 80; }];
        locations."/" = {
          proxyPass = "http://$http_host:80";
          extraConfig = ''
            proxy_bind ${value.address.address};
          '';
        };
      };
    };
    services.nginx.streamConfig = ''
      server {
        resolver ${cfg.resolver} ${lib.strings.optionalString cfg.ipv4Only "ipv6=off"};
        listen ${value.address.address}:443;
        ssl_preread on;
        proxy_pass $ssl_preread_server_name:443;
        proxy_bind ${value.address.address};
      }
    '';
    systemd.services.nginx = {
      after = [ "sys-devices-virtual-net-${name}.device" ];
      bindsTo = [ "sys-devices-virtual-net-${name}.device" ];
    };
  };
  bind = name: value: extraSection: {
    services.bind.enable = true;
    services.bind.listenOn = [ value.address.address ];
    systemd.services.bind.preStart = ''
      set +e
      install -do named ${cfg.folder}
      true
    '';
    services.bind.extraConfig = ''
      view "${name}" {
        response-policy { zone "${name}"; };
        zone "${name}" {
          type master;
          file "${cfg.folder}/${name}.zone";
        };
        ${extraSection}
        ${cfg.bindExtraView}
        match-destinations { ${value.address.address}; };
      };
    '';
  };
  script = name: value: {
    systemd.timers."rkn-${name}" = {
      timerConfig = {
        inherit (cfg) OnCalendar;
      };
      wantedBy = [ "timers.target" ];
    };
    systemd.services."rkn-${name}" = {
      after = [ "rkn-script.service" ];
      description = "Скрипт по активации зоны";
      path = with pkgs; [ coreutils gnused ];
      serviceConfig = {
        ExecStart = pkgs.writeShellScript "rkn-${name}" ''
          set +e
          mkdir -p ${cfg.folder}
          cd ${cfg.folder}
          install -m644 ${pkgs.writeText "local.zone" cfg.header} ${name}.zone
          cat /var/lib/rkn-script/dump.txt | sed -e 's#\(.*\)#\1 IN A ${value.address.address}#' >> ${name}.zone
          systemctl restart bind
        '';
      };
    };
  };
in {
  inherit imports;

  options.services.rkn = {
    enable = mkEnableOption "Обход блокировок роскомпозора";

    transports = mkOption {
      default = {};
      type = types.attrsOf (types.submodule {
        options = {
          address = mkOption {
            type = types.anything;
            example = ''
              ip4.fromString "10.0.0.1/24"
            '';
          };
          torNetwork = mkOption {
            type = types.anything;
            default = ip4.fromString "10.123.0.1/16";
          };
        };
      });
    };

    OnCalendar = mkOption {
      type = types.str;
      default = "weekly";
    };
    folder = mkOption {
      type = types.str;
      default = "/var/lib/rkn";
    };
    header = mkOption {
      type = types.str;
      default = ''
        $TTL 604800 
        @ IN SOA local. root.local. (
          1 ; Serial
          604800 ; Refresh
          86400 ; Retry
          2419200 ; Expire
          604800 ) ; Negative Cache TTL
        @ IN NS localhost.
        localhost. IN A 127.0.0.1
      '';
    };
    bindExtraConfig = mkOption {
      type = types.str;
      default = "";
    };
    bindExtraView = mkOption {
      type = types.str;
      default = "";
    };
    resolver = mkOption {
      type = types.str;
    };
    ipv4Only = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkMerge [

  (mkIf cfg.enable {
    #services.bind.cacheNetworks = [ "any" ];
    services.bind.extraOptions = ''
      check-names master ignore;
      #recursion yes;
    '';
    services.bind.extraConfig = cfg.bindExtraConfig;
    systemd.timers.rkn-script = {
      timerConfig = {
        inherit (cfg) OnCalendar;
      };
      wantedBy = [ "timers.target" ];
    };
    systemd.services.rkn-script = {
      description = "Сервис выгрузки и обработки списка блокировок роскомпозора";
      path = with pkgs; with pkgs.nur.repos.dukzcry; [ gnugrep coreutils gnused libidn glibc gawk git ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "rkn.sh" ''
          set -e
          cd /var/lib/rkn-script
          git remote update
          UPSTREAM=''${1:-'@{u}'}
          LOCAL=$(git rev-parse @)
          REMOTE=$(git rev-parse "$UPSTREAM")
          BASE=$(git merge-base @ "$UPSTREAM")
          if [ $LOCAL = $REMOTE ]; then
            #echo "Up-to-date"
            :
          elif [ $LOCAL = $BASE ]; then
            #echo "Need to pull"
            git pull
            do=0
          elif [ $REMOTE = $BASE ]; then
            #echo "Need to push"
            :
          else
            #echo "Diverged"
            :
          fi
          [ -z $do ] && exit
          # domain column
          cat dump.csv | iconv -f WINDOWS-1251 -t UTF-8 | awk -F ';' '!length($3)' | cut -d ';' -f2 | grep -Eo '^([[:alnum:]]|_|-|\.|\*)+\.[[:alpha:]]([[:alnum:]]|-){1,}' > dump2.txt
          # domain from url
          cat dump.csv | iconv -f WINDOWS-1251 -t UTF-8 | cut -d ';' -f3 | grep -Eo '^https?://[[:alnum:]|.]+/?$' | grep -Eo '([[:alnum:]]|_|-|\.|\*)+\.[[:alpha:]]([[:alnum:]]|-){1,}' >> dump2.txt
          # add root domain for each wildcard domain
          sed -i 's/\(\*\.\)\(.*\)/\2\n&/' dump2.txt
          cat dump2.txt | sort | uniq | idn --no-tld > dump.txt
        '';
      } // serviceOptions;
    };
  })

  (mkIf (hasAttr "tor" cfg.transports) {
    services.tor.enable = true;
    services.tor.client.enable = true;
    services.tor.settings = {
      ExcludeExitNodes = "{RU}";
      DNSPort = [{ addr = tor.address.address; port = 5353; }];
      VirtualAddrNetworkIPv4 = ip4.networkCIDR tor.torNetwork;
      AutomapHostsOnResolve = true;
      TransPort = [{ addr = tor.address.address; port = 9040; }];
    };
    networking.firewall.extraCommands = ''
      iptables -t nat -A PREROUTING -p tcp -d ${ip4.networkCIDR tor.torNetwork} -j DNAT --to-destination ${tor.address.address}:9040
    '';
    programs.tun2socks = {
      enable = true;
      gateways = {
        tor = {
          address = ip4.toCIDR tor.address;
          proxy = "socks5://${config.services.tor.client.socksListenAddress.addr}:${toString config.services.tor.client.socksListenAddress.port}";
          logLevel = "error";
        };
      };
    };
  })
  (mkIf (hasAttr "tor" cfg.transports) (nginx "tor" tor))
  (mkIf (hasAttr "tor" cfg.transports) (bind "tor" tor
      ''
        zone "onion" {
          type forward;
          forward only;
          forwarders { ${tor.address.address} port 5353; };
        };
      ''
  ))
  (mkIf (hasAttr "tor" cfg.transports) (script "tor" tor))

  ];
}
