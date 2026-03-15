{
  pkgs,
  config,
  inputs,
  system,
  homelab,
  stablePkgs,
  unstablePkgs,
  ...
}:
let
  inherit (config.networking) hostName;
  openclawPkgs = import inputs.openclaw-pr {
    inherit system;
    config = {
      permittedInsecurePackages = [
        "openclaw-2026.2.26"
      ];
    };
  };
in
{
  imports = [
    ../../modules/os/defaults.nix
    ../../modules/os/console.nix
    ../../modules/os/dev.nix
    ../../modules/os/podman.nix
    ../../modules/os/users/toyvo.nix
    ../../modules/os/users/chloe.nix
    ../../modules/nixos/defaults.nix
    ../../modules/nixos/filesystems.nix
    ../../modules/nixos/services/ollama.nix
    ../../modules/nixos/containers/podman.nix
    ../../modules/nixos/containers/portainer.nix
    ../../modules/nixos/containers/chat.nix
    ./samba.nix
    ./nextcloud.nix
    ./homepage.nix
    ./qbittorrent.nix
    ./wireguard.nix
    inputs.arion.nixosModules.arion
    inputs.catppuccin.nixosModules.catppuccin
    inputs.dioxus_monorepo.nixosModules.discord_bot
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.default
    inputs.nh.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nixpkgs-unstable.nixosModules.notDetected
    inputs.nur.modules.nixos.default
    inputs.sops-nix.nixosModules.sops
  ];
  home-manager = {
    extraSpecialArgs = {
      inherit
        inputs
        system
        homelab
        stablePkgs
        unstablePkgs
        ;
    };
    sharedModules = [ ./home.nix ];
  };
  hardware.cpu.amd.updateMicrocode = true;
  networking = {
    hostName = "nas";
    firewall = {
      allowedTCPPorts = [
        80
        53
        443
        8080
        7080
        homelab.${hostName}.services.openclaw.port
      ];
      allowedUDPPorts = [
        53
        443
        8080
        7080
      ];
    };
  };
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [ "kvm-amd" ];
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };
  profiles = {
    defaults.enable = true;
    dev.enable = true;
  };
  userPresets.chloe.enable = true;
  userPresets.toyvo.enable = true;
  users.groups.multimedia.members = [
    "chloe"
    "toyvo"
    "nextcloud"
  ];
  fileSystemPresets.boot.enable = true;
  fileSystemPresets.btrfs.enable = true;
  services = {
    bazarr = {
      enable = true;
      openFirewall = true;
      group = "multimedia";
      listenPort = homelab.${hostName}.services.bazarr.port;
    };
    cockpit = {
      enable = true;
      openFirewall = true;
      port = homelab.${hostName}.services.cockpit.port;
      allowed-origins = [ "https://cockpit.diekvoss.net" ];
    };
    coder = {
      enable = true;
      accessUrl = "https://coder.diekvoss.net";
      listenAddress = "0.0.0.0:${toString homelab.${hostName}.services.coder.port}";
    };
    discord_bot = {
      enable = true;
      env_file = config.sops.secrets."discord_bot.env".path;
      env = {
        ADDR = "0.0.0.0";
        PORT = homelab.${hostName}.services.discord_bot.port;
        BASE_URL = "https://toyvo.dev";
      };
    };
    flaresolverr = {
      enable = true;
      openFirewall = true;
      port = homelab.${hostName}.services.flaresolverr.port;
    };
    home-assistant = {
      enable = true;
      package = stablePkgs.home-assistant.override {
        extraComponents = [
          "analytics"
          "google_pubsub"
          "google_translate"
          "html5"
          "isal"
          "met"
          "nest"
          "radio_browser"
          "shopping_list"
          "tplink_omada"
        ];
        extraPackages =
          ps: with ps; [
            grpcio
          ];
      };
      openFirewall = true;
      config = {
        default_config = { };
        homeassistant = {
          name = "Home";
          unit_system = "metric";
          temperature_unit = "F";
        };
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [ homelab.router.ip ];
          server_port = homelab.${hostName}.services.home-assistant.port;
        };
      };
    };
    homepage-dashboard.enable = true;
    immich = {
      enable = true;
      openFirewall = true;
      host = "0.0.0.0";
      port = homelab.${hostName}.services.immich.port;
      group = "multimedia";
      package = stablePkgs.immich;
      database.enableVectors = false;
    };
    jellyfin = {
      enable = true;
      openFirewall = true;
      group = "multimedia";
    };
    lidarr = {
      enable = true;
      openFirewall = true;
      group = "multimedia";
      settings.server.port = homelab.${hostName}.services.lidarr.port;
    };
    nextcloud.enable = true;
    nix-serve = {
      enable = true;
      openFirewall = true;
      secretKeyFile = config.sops.secrets."cache-priv-key.pem".path;
      port = homelab.${hostName}.services.nix-serve.port;
    };
    ollama = {
      enable = true;
      port = homelab.${hostName}.services.ollama.port;
    };
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    # Immich doesn't support postgresql_17 yet;
    postgresql.package = pkgs.postgresql_16;
    prowlarr = {
      enable = true;
      openFirewall = true;
      settings.server.port = homelab.${hostName}.services.prowlarr.port;
    };
    radarr = {
      enable = true;
      openFirewall = true;
      group = "multimedia";
      settings.server.port = homelab.${hostName}.services.radarr.port;
    };
    readarr = {
      enable = true;
      openFirewall = true;
      group = "multimedia";
      settings.server.port = homelab.${hostName}.services.readarr.port;
    };
    samba.enable = true;
    sonarr = {
      enable = true;
      openFirewall = true;
      group = "multimedia";
      settings.server.port = homelab.${hostName}.services.sonarr.port;
    };
    spice-vdagentd.enable = true;
    qbittorrent.enable = true;
  };
  containerPresets = {
    podman.enable = true;
    open-webui = {
      enable = true;
      openFirewall = true;
      dataDir = "/mnt/POOL/open-webui";
      port = homelab.${hostName}.services.open-webui.port;
    };
    portainer = {
      enable = true;
      openFirewall = true;
      sport = homelab.${hostName}.services.portainer.port;
    };
  };
  fileSystems."/mnt/POOL" = {
    device = "/dev/disk/by-label/POOL";
    fsType = "btrfs";
  };

  users.users = {
    toyvo.extraGroups = [ "libvirtd" ];
    jellyfin.extraGroups = [
      "video"
      "render"
    ];
    openclaw = {
      isSystemUser = true;
      group = "openclaw";
    };
  };
  users.groups.openclaw = { };

  systemd.services.openclaw = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "openclaw";
      Group = "openclaw";
      # Ensure OpenClaw has a directory to store its identity/memory/state
      StateDirectory = "openclaw";
      # The application should point to this directory for state
      Environment = [
        "OPENCLAW_HOME=/var/lib/openclaw"
        "GEMINI_API_KEY_FILE=${config.sops.secrets."openclaw_gemini.key".path}"
      ];
      ExecStart = "${openclawPkgs.openclaw}/bin/openclaw gateway --port ${toString homelab.${hostName}.services.openclaw.port}";
      Restart = "always";
    };
  };
  home-manager.users.toyvo.programs.beets.settings.directory = "/mnt/POOL/Public/Music";
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    bottles
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    guestfs-tools
    libosinfo
    win-spice
    distrobox
  ];
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
    spiceUSBRedirection.enable = true;
  };
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };
  sops.secrets."cache-priv-key.pem" = { };
  sops.secrets."discord_bot.env" = {
    owner = "discord_bot";
    group = "discord_bot";
  };
  sops.secrets."openclaw_gemini.key" = {
    owner = "openclaw";
    group = "openclaw";
    mode = "0400";
  };
}
