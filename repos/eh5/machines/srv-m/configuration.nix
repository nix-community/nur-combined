{ config, pkgs, lib, ... }:
let
  secrets = config.sops.secrets;
  dovecotUser = config.services.dovecot2.user;
  postfixUser = config.services.postfix.user;
  rspamdUser = config.services.rspamd.user;
  caddyUser = config.services.caddy.user;
in
{
  sops = {
    defaultSopsFormat = "yaml";
    defaultSopsFile = ./secrets/secrets.yaml;
    secrets = {
      acmeEnv = { };
      postScript = { mode = "0500"; };
      trustedNetworks = { };
      bindDnPw = { };
      passdbLdap.owner = dovecotUser;
      # sieveLdap = { mode = "440"; owner = dovecotUser; };
      vaccountLdap.owner = postfixUser;
      valiasLdap.owner = postfixUser;
      "eh5.me.dkim.key".owner = rspamdUser;
      "sokka.cn.dkim.key".owner = rspamdUser;
      "chika.xin.dkim.key".owner = rspamdUser;
      webConfig.owner = caddyUser;
      v2rayConfig = {
        name = "v2ray.json";
        format = "binary";
        sopsFile = ./secrets/v2ray.v5.json.sops;
      };
      mailCryptPrivKey = {
        name = "ecprivkey.pem";
        format = "binary";
        sopsFile = ./secrets/ecprivkey.pem.sops;
      };
      mailCryptPubKey = {
        name = "ecpubkey.pem";
        format = "binary";
        sopsFile = ./secrets/ecpubkey.pem.sops;
      };
      "dc_eh5_dc_me.ldif" = {
        format = "binary";
        sopsFile = ./secrets/dc_eh5_dc_me.ldif.sops;
        owner = config.services.openldap.user;
        restartUnits = [ "openldap.service" ];
      };
    };
  };

  nix = {
    settings = {
      substituters = lib.mkForce [
        "https://cache.nixos.org"
        "https://eh5.cachix.org"
      ];
      trusted-public-keys = [ "eh5.cachix.org-1:pNWZ2OMjQ8RYKTbMsiU/AjztyyC8SwvxKOf6teMScKQ=" ];
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
  };
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "22.05";

  networking.hostName = "srv-m";
  networking.hosts = {
    "127.0.0.1" = [ "mx.eh5.me" ];
    "::1" = [ "mx.eh5.me" ];
  };

  time.timeZone = "Asia/Shanghai";

  documentation.man.enable = true;
  documentation.dev.enable = false;
  documentation.doc.enable = false;
  documentation.nixos.enable = false;

  programs.command-not-found.enable = true;
  programs.vim.defaultEditor = true;
  programs.git.enable = true;

  services.openssh = {
    enable = true;
    settings.permitRootLogin = "yes";
    ports = lib.mkForce [ 8022 ];
  };

  system.autoUpgrade = {
    enable = false;
    dates = "04:00";
    randomizedDelaySec = "60min";
    flake = "github:EHfive/flakes";
    allowReboot = true;
  };
  nix.gc.automatic = true;
  nix.optimise.automatic = true;

  users.users.root = {
    initialHashedPassword = "$6$I7u4S2QGNHl7OG5g$ClRYXRX0kZ1VtiyrGta.7EG0pkdGhVrattNX9j.H71iTgnafT7gzyli9sEuvk0oSJ7YrH6OiOmmJuIh40BPEa1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3wDrWMAdPILZrRGggLHrvV3qsctMS/TrQkFdc4c81r"
    ];
  };

  environment.systemPackages = with pkgs; [
    bind
    caddy
    file
    htop
    iperf
    libarchive
    lm_sensors
    lsof
    screen
    v2ray-next
  ] ++ (with config.boot.kernelPackages; [
    cpupower
  ]);
}
