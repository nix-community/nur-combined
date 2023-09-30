{ config, pkgs, lib, ... }:
{
  system.activationScripts.clash = lib.stringAfter [ "users" ] ''
    mkdir -p /etc/clash
    chown -R clash:clash /etc/clash
  '';

  users.users.clash = {
    description = "Clash deamon user";
    isSystemUser = true;
    group = "clash";
  };
  users.groups.clash = { };

  environment = {
    systemPackages = with pkgs; [
      clash-geoip
    ];
    etc."clash/Country.mmdb".source = "${pkgs.clash-geoip}/etc/clash/Country.mmdb";
    etc."clash/yacd".source = config.nur.repos.linyinfeng.yacd;
    etc."clash/config.yaml".source = ./home.yaml;
  };

  systemd.services.clash = {
    path = with pkgs; [ clash ];
    description = "Clash networking service";
    after = [ "network.target" "sops-nix.service" "smartdns.service" ];
    wantedBy = [ "multi-user.target" ];
    script = "exec clash -d /etc/clash -secret $(cat ${config.sops.secrets.clash_secret.path})";

    serviceConfig = {
      # CAP_NET_BIND_SERVICE: Bind arbitary ports by unprivileged user.
      # CAP_NET_ADMIN: Listen on UDP.
      AmbientCapabilities =
        "CAP_NET_BIND_SERVICE CAP_NET_ADMIN"; # We want additional capabilities upon a unprivileged user.
      User = "clash";
      Restart = "on-failure";
    };
  };

  sops.secrets.clash_secret = {
    owner = "clash";
    restartUnits = [ "clash.service" ];
  };

  sops.secrets.clash = {
    format = "yaml";
    key = "";
    sopsFile = ../../secrets/clash.yaml;
    owner = "clash";
    path = "/etc/clash/combination.yaml";
    restartUnits = [ "clash.service" ];
  };

  networking.firewall.allowedTCPPorts = [
    7890 # http_proxy
    9090 # clashctl
  ];
}
