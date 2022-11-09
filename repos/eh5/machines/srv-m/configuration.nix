{ config, pkgs, lib, ... }:
let
  secrets = config.sops.secrets;
  rspamdUser = config.services.rspamd.user;
in
{
  sops = {
    defaultSopsFormat = "yaml";
    defaultSopsFile = ./secrets/secrets.yaml;
    secrets = {
      acmeEnv = { };
      postScript = { mode = "0500"; };
      trustedNetworks = { };
      passwdFile = { };
      vaccounts = { };
      virtual = { };
      vmailbox = { };
      "eh5.me.dkim.key".owner = rspamdUser;
      "sokka.cn.dkim.key".owner = rspamdUser;
      "chika.xin.dkim.key".owner = rspamdUser;
    };
  };
  sops.secrets.v2rayConfig = {
    name = "v2ray.json";
    format = "binary";
    sopsFile = ./secrets/v2ray.v5.json.sops;
  };
  sops.secrets.mailCryptPrivKey = {
    name = "ecprivkey.pem";
    format = "binary";
    sopsFile = ./secrets/ecprivkey.pem.sops;
  };
  sops.secrets.mailCryptPubKey = {
    name = "ecpubkey.pem";
    format = "binary";
    sopsFile = ./secrets/ecpubkey.pem.sops;
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
  system.stateVersion = config.system.nixos.release;

  networking.hostName = "srv-m";

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
    permitRootLogin = "yes";
    ports = lib.mkForce [ 8080 ];
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

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "i+acme@eh5.me";
      keyType = "ec256";
      dnsProvider = "cloudflare";
      credentialsFile = secrets.acmeEnv.path;
    };
    certs."eh5.me" = {
      extraDomainNames = [
        "sokka.cn"
        "*.eh5.me"
        "*.sokka.cn"
      ];
      postRun = ''
        export PATH="$PATH:${pkgs.sshpass}/bin"
        bash ${secrets.postScript.path}
      '';
    };
  };
  security.dhparams.enable = true;

  services.v2ray-next = {
    enable = true;
    useV5Format = true;
    configFile = config.sops.secrets.v2rayConfig.path;
  };

  environment.systemPackages = with pkgs; [
    bind
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
