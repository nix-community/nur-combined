libidn: { config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.rkn;
  ip4 = pkgs.nur.repos.dukzcry.lib.ip4;
  router = ip4.next cfg.address;
in {
  options.services.rkn = {
    enable = mkEnableOption "Обход блокировок роскомпозора";
    interface = mkOption {
      type = types.str;
      default = "tun0";
    };
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
    };

    networking.interfaces.${cfg.interface} = {
      ipv4.addresses = [ (ip4.toNetworkAddress cfg.address) ];
      virtual = true;
    };

    systemd.services.rkn-server = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-addresses-${cfg.interface}.service" ];
      bindsTo = [ "network-addresses-${cfg.interface}.service" ];
      description = "Шлюз для обхода блокировок роскомпозора";
      path = with pkgs; [ iproute2 ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.badvpn}/bin/badvpn-tun2socks \
            --tundev ${cfg.interface} \
            --netif-ipaddr ${router.address} \
            --netif-netmask ${ip4.netmask' cfg.address} \
            --socks-server-addr ${config.services.tor.client.socksListenAddress.addr}:${toString config.services.tor.client.socksListenAddress.port}
        '';
      };
      postStart = ''
        set +e
        ip rule add from ${cfg.address.address} table ${toString cfg.table}
        ip route add default dev ${cfg.interface} table ${toString cfg.table}
        ip rule add from ${cfg.address.address} table main suppress_prefixlength 0
        ${cfg.postStart}
        true
      '';
      preStop = ''
        set +e
        ip rule del from ${cfg.address.address} table ${toString cfg.table}
        ip route del default dev ${cfg.interface} table ${toString cfg.table}
        ip rule del from ${cfg.address.address} table main suppress_prefixlength 0
        ${cfg.preStop}
        true
      '';
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
          cat dump.csv | iconv -f WINDOWS-1251 -t UTF-8 | awk -F ';' '!length($3)' | cut -d ';' -f2 | grep -Eo '^([[:alnum:]]|_|-|\.|\*)+\.[[:alpha:]]([[:alnum:]]|-){1,}' > dump.txt
          cat dump.csv | iconv -f WINDOWS-1251 -t UTF-8 | cut -d ';' -f3 | grep -Eo '^https?://[[:alnum:]|.]+/?$' | grep -Eo '([[:alnum:]]|_|-|\.|\*)+\.[[:alpha:]]([[:alnum:]]|-){1,}' >> dump.txt
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
      after = [ "network-addresses-${cfg.interface}.service" ];
      bindsTo = [ "network-addresses-${cfg.interface}.service" ];
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
        ${cfg.bindExtraConfig}
      };
    '';
  };

}
