{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  documentation = {
    info.enable = false;
    nixos.enable = false;
    man.man-db.enable = lib.mkForce false;
  };
  environment.systemPackages = with pkgs; [
    lsof
    wireguard-tools
    tcpdump
  ];
  system = {
    # server.
    stateVersion = "25.11";
    etc.overlay.enable = true;
    etc.overlay.mutable = false;
  };

  users.mutableUsers = false;
  services.userborn.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  boot = {
    supportedFilesystems = [ "tcp_bbr" ];
  };

  repack = {
    plugIn.enable = true;
    openssh.enable = true;
    fail2ban.enable = true;
    sing-server.enable = true;
    rustypaste.enable = true;
    subs.enable = true;
  };
  services = {
    metrics.enable = true;
    coturn = {
      enable = true;
      # static-auth-secret-file = config.vaultix.secrets.wg.path;
      no-auth = true;
      realm = config.networking.fqdn;
    };

    # factorio-manager = {
    #   enable = true;
    #   factorioPackage = pkgs.factorio-headless-experimental.override {
    #     versionsJson = ./factorio-version.json;
    #   };
    #   botConfigPath = config.vaultix.secrets.factorio-manager-bot.path;
    #   initialGameStartArgs = [
    #     "--server-settings=${config.vaultix.secrets.factorio-server.path}"
    #     "--server-adminlist=${config.vaultix.secrets.factorio-admin.path}"
    #   ];
    # };

    ntfy-sh = {
      enable = true;
      settings = {
        listen-http = ":2586";
        behind-proxy = true;
        auth-default-access = "deny-all";
        base-url = "http://ntfy.nyaw.xyz";
      };
    };

    hysteria.instances = {
      only = {
        enable = true;
        serve = true;
        openFirewall = 4432;
        credentials = [
          "key:${config.vaultix.secrets."nyaw.key".path}"
          "crt:${config.vaultix.secrets."nyaw.cert".path}"
        ];
        configFile = config.vaultix.secrets.hyst-us.path;
      };
    };
  };
  systemd.tmpfiles.rules = [ ];
}
