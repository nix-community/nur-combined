{
  config,
  pkgs,
  lib,
  ...
}:
let
  nftBin = "${pkgs.nftables}/bin/nft";
  startScript = pkgs.writeScript "setup-tproxy-start" ''
    #!${nftBin} -f
    table ip my_tproxy {}
    flush table ip my_tproxy
    include "${config.sops.secrets."tproxy.nft".path}"
  '';
  stopScript = pkgs.writeScript "setup-tproxy-stop" ''
    #!${nftBin} -f
    table ip my_tproxy {}
    delete table ip my_tproxy
  '';
  buildChnroutesSetScript = pkgs.writeShellScript "build-chnroutes-set" ''
    export PATH="$PATH''${PATH:+:}${pkgs.curl}/bin:${pkgs.gnused}/bin"
    ${builtins.readFile ./files/build-chnroutes-set.sh}
  '';
  inherit (config.sops) secrets;
in
{
  users.groups.direct-net = { };

  systemd.services.sing-box = {
    serviceConfig = {
      CPUQuota = "90%";
      SupplementaryGroups = [ config.users.groups.direct-net.name ];
    };
  };

  services.sing-box = {
    enable = true;
    settings = {
      log.level = "warn";
      dns = {
        servers = [
          {
            tag = "local";
            type = "tcp";
            server = "127.0.0.1";
            server_port = 5333;
          }
        ];
        strategy = "ipv4_only";
      };
      route = {
        default_domain_resolver = "local";
        default_interface = "extern0";
        default_mark = 255;
      };
      inbounds = [
        {
          tag = "tun-in";
          type = "tun";
          interface_name = "tun0";
          address = [
            "198.18.0.1/15"
          ];
          mtu = 1500;
          auto_route = false;
          stack = "gvisor";
          udp_timeout = 60;
          endpoint_independent_nat = true;
          sniff = true;
        }
      ];
    };
  };
  systemd.services.sing-box.preStart = ''
    cp ${secrets."sb-config.json".path} /run/sing-box/other.json
  '';
  sops.secrets."sb-config.json".restartUnits = [ "sing-box.service" ];
  services.v2ray-rules-dat.reloadServices = [ "sing-box.service" ];

  systemd.services.kcptun = {
    description = "kcptun";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.kcptun}/bin/kcptun-client -c ${secrets."kcptun.json".path}
    '';
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 4;
    };
  };
  sops.secrets."kcptun.json".restartUnits = [ "kcptun.service" ];

  systemd.services.udpspeeder = {
    description = "UDPspeeder";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      xargs -a ${secrets."udpspeeder.conf".path} ${pkgs.udpspeeder}/bin/speederv2
    '';
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 4;
    };
  };
  sops.secrets."udpspeeder.conf".restartUnits = [ "udpspeeder.service" ];

  # systemd.services.udp2raw = {
  #   description = "udp2raw";
  #   wants = [ "network-online.target" ];
  #   after = [ "network-online.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   script = ''
  #     xargs -a ${secrets."udp2raw.conf".path} ${pkgs.udp2raw}/bin/udp2raw
  #   '';
  #   serviceConfig = {
  #     Restart = "on-failure";
  #     RestartSec = 4;
  #   };
  # };
  # sops.secrets."udp2raw.conf".restartUnits = [ "udp2raw.service" ];

  systemd.services.setup-tproxy = {
    unitConfig.ReloadPropagatedFrom = [ "nftables.service" ];
    bindsTo = [ "nftables.service" ];
    wants = [ "systemd-time-wait-sync.service" ];
    after = [
      "systemd-time-wait-sync.service"
      "nftables.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = startScript;
      ExecReload = startScript;
      ExecStop = stopScript;
      RemainAfterExit = true;
    };
    reloadIfChanged = true;
  };
  sops.secrets."tproxy.nft".reloadUnits = [ "setup-tproxy.service" ];

  systemd.services.update-chnroutes = {
    serviceConfig.Type = "oneshot";
    script = ''
      ${buildChnroutesSetScript}
      ${pkgs.systemd}/bin/systemctl reload setup-tproxy.service
    '';
  };

  systemd.timers.update-chnroutes = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "60min";
      Persistent = true;
    };
  };

  system.activationScripts.update-chnroutes.text = ''
    ${buildChnroutesSetScript} -a
  '';
}
