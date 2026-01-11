{
  config,
  pkgs,
  lib,
  ...
}:
{
  sops = {
    defaultSopsFormat = "yaml";
    defaultSopsFile = ./secrets/secrets.sops.yaml;
    secrets = {
      # "sb-config.json" = {
      #   owner = "sing-box";
      # };
      "mosdns.yaml" = { };
      "tproxy.nft" = { };
      "v2ray.v5.json" = { };
      "udpspeeder.conf" = { };
    };
  };

  nix = {
    settings = {
      substituters = lib.mkForce [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
        "https://eh5.cachix.org"
      ];
      trusted-public-keys = [ "eh5.cachix.org-1:pNWZ2OMjQ8RYKTbMsiU/AjztyyC8SwvxKOf6teMScKQ=" ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
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
  programs.vim.enable = true;
  programs.vim.defaultEditor = true;
  programs.git.enable = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  services.redis.package = pkgs.valkey;

  services.vlmcsd.enable = true;

  system.autoUpgrade = {
    enable = false;
    dates = "04:00";
    randomizedDelaySec = "60min";
    flake = "github:EHfive/flakes";
    allowReboot = true;
  };
  nix.gc.automatic = true;
  nix.gc.options = "-d";
  nix.optimise.automatic = true;

  users.users.root = {
    initialHashedPassword = "$6$I7u4S2QGNHl7OG5g$ClRYXRX0kZ1VtiyrGta.7EG0pkdGhVrattNX9j.H71iTgnafT7gzyli9sEuvk0oSJ7YrH6OiOmmJuIh40BPEa1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3wDrWMAdPILZrRGggLHrvV3qsctMS/TrQkFdc4c81r"
    ];
  };

  environment.systemPackages =
    with pkgs;
    [
      bind
      bpftools
      busybox
      conntrack-tools
      ethtool
      f2fs-tools
      file
      gdb
      htop
      iperf
      libgpiod
      lm_sensors
      lsof
      mtr
      python3
      rtl8152-led-ctrl
      screen
      sops
      stuntman
      tcpdump
      traceroute
      usbutils
      sing-box
    ]
    ++ (with config.boot.kernelPackages; [
      cpupower
    ]);
}
