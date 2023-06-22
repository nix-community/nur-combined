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
    etc."clash/config.yaml".source = if config.networking.proxy.httpsProxy == null then ./office.yaml else ./home.yaml;
  };

  systemd.services.clash = {
    path = with pkgs; [ clash ];
    description = "Clash networking service";
    after = [ "network.target" "sops-nix.service" ];
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [
      config.environment.etc."clash/config.yaml".source
      config.sops.secrets.clash.sopsFile
    ];
    script = "exec clash -d /etc/clash -secret $(cat ${config.sops.secrets.clash_secret.path})";

    # Don't start if the config file doesn't exist.
    unitConfig = {
      # NOTE: configPath is for the original config which is linked to the following path.
      ConditionPathExists = [
        "/etc/clash/config.yaml"
        config.sops.secrets.clash_secret.path
      ];
    };
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
  };

  sops.secrets.clash = {
    format = "yaml";
    key = "";
    sopsFile = ../../secrets/clash.yaml;
    owner = "clash";
    path = "/etc/clash/combination.yaml";
  };

  networking.firewall.allowedTCPPorts = [
    7890 # http_proxy
    9090 # clashctl
  ];
}
