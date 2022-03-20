libidn: imports: { config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.rkn;
  ip4 = pkgs.nur.repos.dukzcry.lib.ip4;
  # damn flibusta
  tor = ip4.fromString "10.123.0.1/16";
in {
  inherit imports;

  options.services.rkn = {
    enable = mkEnableOption "Обход блокировок роскомпозора";
    address = mkOption {
      type = types.anything;
      example = ''
        ip4.fromString "10.0.0.1/24"
      '';
    };
    table = mkOption {
      type = types.ints.positive;
      default = 1;
    };
    postStart = mkOption {
      type = types.str;
      default = "";
    };
    preStop = mkOption {
      type = types.str;
      default = "";
    };
    OnCalendar = mkOption {
      type = types.str;
      default = "weekly";
    };
    file = mkOption {
      type = types.str;
      default = "/var/lib/rkn/rkn.zone";
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
      example = ''
        match-clients { ''${ip4.networkCIDR iif.ip}; };
      '';
    };
    resolver = mkOption {
      type = types.str;
    };
    ipv4Only = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    services.tor.enable = true;
    services.tor.client.enable = true;
    services.tor.settings = {
      ExcludeExitNodes = "{RU}";
      DNSPort = [{ addr = cfg.address.address; port = 53; }];
      VirtualAddrNetworkIPv4 = ip4.networkCIDR tor;
      AutomapHostsOnResolve = true;
      TransPort = [{ addr = cfg.address.address; port = 9040; }];
    };
    networking.firewall.extraCommands = ''
      iptables -t nat -A PREROUTING -p tcp -d ${ip4.networkCIDR tor} -j DNAT --to-destination ${cfg.address.address}:9040
    '';

    programs.tun2socks = {
      enable = true;
      gateways = {
        tor = {
          address = cfg.address.address;
          proxy = "socks5://${config.services.tor.client.socksListenAddress.addr}:${toString config.services.tor.client.socksListenAddress.port}";
        };
      };
    };

    systemd.timers.rkn-script = {
      timerConfig = {
        inherit (cfg) OnCalendar;
      };
      wantedBy = [ "timers.target" ];
    };
    systemd.services.rkn-script = {
      description = "Сервис выгрузки и обработки списка блокировок роскомпозора";
      path = with pkgs; [ gnugrep wget coreutils gnused libidn glibc gawk ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = (pkgs.writeShellScriptBin "rkn.sh" ''
          set -e
          cd ${dirOf cfg.file}
          wget --backups=3 https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv
          # domain column
          cat dump.csv | iconv -f WINDOWS-1251 -t UTF-8 | awk -F ';' '!length($3)' | cut -d ';' -f2 | grep -Eo '^([[:alnum:]]|_|-|\.|\*)+\.[[:alpha:]]([[:alnum:]]|-){1,}' > dump.txt
          # domain from url
          cat dump.csv | iconv -f WINDOWS-1251 -t UTF-8 | cut -d ';' -f3 | grep -Eo '^https?://[[:alnum:]|.]+/?$' | grep -Eo '([[:alnum:]]|_|-|\.|\*)+\.[[:alpha:]]([[:alnum:]]|-){1,}' >> dump.txt
          # add root domain for each wildcard domain
          sed -i 's/\(\*\.\)\(.*\)/\2\n&/' dump.txt
          install -m644 ${pkgs.writeText "local.zone" cfg.header} ${cfg.file}
          cat dump.txt | sort | uniq | idn --no-tld | sed -e 's#\(.*\)#\1 IN A ${cfg.address.address}#' >> ${cfg.file}
          systemctl restart bind
        '') + "/bin/rkn.sh";
      };
    };

    services.nginx.enable = true;
    services.nginx.proxyResolveWhileRunning = true;
    services.nginx.resolver = {
      addresses = [ cfg.resolver ];
      ipv6 = !cfg.ipv4Only;
    };
    services.nginx.virtualHosts = { 
      rkn = {
        default = true;
        listen = [{ addr = cfg.address.address; port = 80; }];
        locations."/" = {
          proxyPass = "http://$http_host:80";
          extraConfig = ''
            proxy_bind ${cfg.address.address};
          '';
        };
      };
    };
    services.nginx.streamConfig = ''
      server {
        resolver ${cfg.resolver} ${lib.strings.optionalString cfg.ipv4Only "ipv6=off"};
        listen ${cfg.address.address}:443;
        ssl_preread on;
        proxy_pass $ssl_preread_server_name:443;
        proxy_bind ${cfg.address.address};
      }
    '';
    systemd.services.nginx = {
      after = [ "tun2socks-tor-script.service" ];
      bindsTo = [ "tun2socks-tor-script.service" ];
    };

    services.bind.enable = true;
    services.bind.extraOptions = ''
      check-names master ignore;
    '';
    systemd.services.bind.preStart = ''
      set +e
      install -do named ${dirOf cfg.file}
      true
    '';
    services.bind.extraConfig = ''
      view "rkn" {
        response-policy { zone "rkn"; };
        zone "rkn" {
          type master;
          file "${cfg.file}";
        };
        zone "onion" {
          type forward;
          forward only;
          forwarders { ${cfg.address.address}; };
        };
        ${cfg.bindExtraConfig}
      };
    '';
  };

}
