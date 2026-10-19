{
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [
    ./ricing.nix
    ./system.nix
    ./home.nix
  ];
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;

    brews = [
      "openssl"
      "wget"
      "git-crypt"
      "docker"
      "docker-compose"
      "nohajc/anylinuxfs/anylinuxfs"
      "mole"
      "chromaprint"
    ];

    casks = [
      "android-studio"
      "foks"
      "raycast"
      "anylinuxfs-gui"
      "keybase"
      "tailscale-app"
      "boring-notch"
      "linearmouse"
      "cloudflare-warp"
      # "sikarugir"
      "vorssaint"
    ];

    masApps = {
      # Xcode = 497799835;
    };

    taps = builtins.attrNames config.nix-homebrew.taps;
  };

  environment.systemPackages = [
    pkgs.colima
    pkgs.coreutils
    pkgs.zstd
    pkgs.duf
    pkgs.ffmpeg
    pkgs.syncthing-macos
    # pkgs.qemu
    # pkgs.quickemu
    pkgs.nur.repos.forkprince.helium-nightly
    inputs.nix-auth.packages.aarch64-darwin.default
    pkgs.ghostty-bin
  ];

  # services.virby.enable = false;
  # services.virby.onDemand.enable = false;
  # services.virby.onDemand.ttl = 10;
  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.watchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;

  environment.etc."zshrc".enable = false;

  networking = {
    computerName = "Avyays MacBook Air";
    hostName = "Avys-Mac";
    localHostName = "Avys-Mac";

    dns = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];

    knownNetworkServices = [
      "Raspberry Pi Compute Module 4 Rev 1.1"
      "USB 10/100/1000 LAN"
      "Thunderbolt Ethernet"
      "Thunderbolt Bridge"
      "Wi-Fi"
    ];
  };

  system = {
    stateVersion = 5;
    primaryUser = "avy";
  };

  users.users.avy = {
    name = "avy";
    home = "/Users/avy";
    shell = pkgs.zsh;
  };
  # nix.linux-builder.enable = true; doesnt seem to work rn; will reimplement
}
