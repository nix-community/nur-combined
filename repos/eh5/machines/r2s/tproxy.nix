{ config, pkgs, lib, ... }:
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
  # clashUi = pkgs.fetchTarball "https://github.com/MetaCubeX/Yacd-meta/archive/gh-pages.zip";
  inherit (config.sops) secrets;
in
{
  users.groups.direct-net = { };

  services.v2ray-next = {
    enable = false;
    package = pkgs.v2ray-next.override {
      assetsDir = config.services.v2ray-rules-dat.dataDir;
    };
    useV5Format = true;
    configFile = secrets.v2rayConfig.path;
  };
  # systemd.services.v2ray-next = {
  #   serviceConfig = {
  #     TimeoutSec = 5;
  #     SupplementaryGroups = [ config.users.groups.direct-net.name ];
  #   };
  # };
  # services.v2ray-rules-dat.reloadServices = [ "v2ray-next.service" ];
  # sops.secrets.v2rayConfig.restartUnits = [ "v2ray-next.service" ];

  services.sing-box = {
    enable = true;
    settings = {
      log.level = "warn";
      dns = {
        servers = [{
          address = "udp://127.0.0.1:5333";
          detour = "direct";
        }];
        strategy = "ipv4_only";
      };
      route = {
        default_interface = "extern0";
        default_mark = 255;
      };
      inbounds = [
        {
          tag = "tun-in";
          type = "tun";
          interface_name = "tun0";
          inet4_address = "198.18.0.1/15";
          mtu = 9000;
          auto_route = false;
          stack = "gvisor";
          endpoint_independent_nat = true;
          sniff = true;
        }
      ];
    };
  };
  environment.etc."sing-box/other.json".source = secrets."sb-config.json".path;
  sops.secrets."sb-config.json".restartUnits = [ "sing-box.service" ];
  services.v2ray-rules-dat.reloadServices = [ "sing-box.service" ];

  systemd.services.udpspeeder = {
    description = "UDPspeeder";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      xargs -a ${secrets."udpspeeder.conf".path} ${pkgs.udpspeeder}/bin/speederv2
    '';
  };
  sops.secrets."udpspeeder.conf".restartUnits = [ "udpspeeder.service" ];

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
