{ config, pkgs, lib, ... }:
{
  sops.defaultSopsFormat = "binary";
  sops.secrets.mosdnsConfig = {
    name = "mosdns.yaml";
    sopsFile = ./secrets/mosdns.yaml.sops;
  };
  sops.secrets.tproxyRule.sopsFile = ./secrets/tproxy.nft.sops;
  sops.secrets.v2rayConfig = {
    name = "v2ray.json";
    sopsFile = ./secrets/v2ray.v4.json.sops;
  };

  nix = {
    settings = {
      substituters = lib.mkForce [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
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

  networking.hostName = "nixos-r2s";

  time.timeZone = "Asia/Shanghai";

  documentation.man.enable = true;
  documentation.dev.enable = false;
  documentation.doc.enable = false;
  documentation.nixos.enable = false;

  programs.command-not-found.enable = true;
  programs.vim.defaultEditor = true;

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  services.vlmcsd.enable = true;

  system.autoUpgrade = {
    enable = true;
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
    f2fs-tools
    file
    htop
    iperf2
    lm_sensors
    lsof
    screen
    usbutils
    v2ray-next
    vlmcsd
  ] ++ (with config.boot.kernelPackages; [
    cpupower
  ]);
}
