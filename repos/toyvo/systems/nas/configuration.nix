{
  pkgs,
  config,
  inputs,
  system,
  homelab,
  stablePkgs,
  unstablePkgs,
  lib,
  ...
}:
let
  inherit (config.networking) hostName;
in
{
  imports = [
    inputs.nixcfg.modules.os.defaults
    inputs.nixcfg.modules.os.console
    inputs.nixcfg.modules.os.dev
    inputs.nixcfg.modules.os.podman
    inputs.nixcfg.modules.os.users.toyvo
    inputs.nixcfg.modules.os.users.chloe
    inputs.nixcfg.modules.nixos.defaults
    inputs.nixcfg.modules.nixos.filesystems
    inputs.nixcfg.modules.nixos.services.ollama
    inputs.nixcfg.modules.nixos.containers.podman
    inputs.nixcfg.modules.nixos.containers.portainer
    inputs.nixcfg.modules.nixos.containers.starr
    inputs.nixcfg.modules.nixos.containers.chat
    inputs.nixcfg.modules.nixos.containers.monitoring
    inputs.nixcfg.modules.nixos.containers.jellyfin
    inputs.nixcfg.modules.nixos.containers.home-assistant
    inputs.nixcfg.modules.nixos.monitoring.default
    ./samba.nix
    ./nextcloud.nix
    ./homepage.nix
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
        5432
        8080
        7080
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
    cockpit = {
      enable = true;
      openFirewall = true;
      port = homelab.${hostName}.services.cockpit.port;
      allowed-origins = [ "https://cockpit.diekvoss.net" ];
      plugins = with pkgs; [
        cockpit-machines
        cockpit-podman
        cockpit-files
      ];
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
    homepage-dashboard.enable = true;
    immich = {
      enable = true;
      openFirewall = true;
      host = "0.0.0.0";
      port = homelab.${hostName}.services.immich.port;
      group = "multimedia";
      package = stablePkgs.immich;
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
    postgresql = {
      package = pkgs.postgresql_16;
      enableTCPIP = true;
      authentication = lib.mkOverride 10 ''
        local all postgres         peer map=postgres
        local all all              peer
        host  all all 127.0.0.1/32 md5
        host  all all ::1/128      md5
        host  dioxus_music  dioxus_music  10.1.0.0/16  scram-sha-256
        host  discord_bot  discord_bot  10.1.0.0/16  scram-sha-256
      '';
    };
    samba.enable = true;
    spice-vdagentd.enable = true;
    monitoring.enable = true;
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
    jellyfin = {
      enable = true;
      natInterface = "eno1";
      stateDir = "/mnt/POOL/jellyfin";
      mediaDir = "/mnt/POOL/Public";
    };
    home-assistant = {
      enable = true;
      natInterface = "eno1";
      stateDir = "/mnt/POOL/home-assistant";
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
        extraPackages = ps: with ps; [ grpcio ];
      };
      haConfig = {
        default_config = { };
        homeassistant = {
          name = "Home";
          unit_system = "metric";
          temperature_unit = "F";
        };
      };
    };
    monitoring = {
      enable = true;
      stateDir = "/mnt/POOL/monitoring";
      grafanaAdminPasswordFile = config.sops.secrets."grafana-admin-password".path;
      grafanaSecretKeyFile = config.sops.secrets."grafana-secret-key".path;
    };
    starr = {
      enable = true;
      natInterface = "eno1";
      hostAddress = "10.200.0.1";
      localAddress = "10.200.0.2";
      stateDir = "/mnt/POOL/starr";
      # this dir is also exposed via samba
      mediaDir = "/mnt/POOL/Public";
      protonvpn = {
        privateKeyFile = config.sops.secrets."protonvpn-US-IL-503.key".path;
        publicKey = "Ad0UnBi3NeIgVpM1baC8HAp6wfSli0wGS1OCmS7uYRo=";
        endpoint = "79.127.187.156:51820";
      };
      qbittorrent.serverConfig = {
        Preferences = {
          WebUI = {
            Username = "toyvo";
            Password_PBKDF2 = "@ByteArray(w/tVwkQ82PheDXAAMg5D7A==:exy5JA4JdCm7pZ6n0cci16mEmZYxSaFe642TmZBvq9MIzps3tnZY7vbUIj3esJNClzy/YrRI4Dkexg1luhSveg==)";
          };
          General.Locale = "en";
        };
      };
    };
  };
  fileSystems."/mnt/POOL" = {
    device = "/dev/disk/by-label/POOL";
    fsType = "btrfs";
  };
  users.users.toyvo.extraGroups = [ "libvirtd" ];
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
  # Grafana credentials are bind-mounted into the monitoring container where the grafana user
  # reads them via $__file{}. mode 0444 allows any process (including container-side grafana) to
  # read them without needing to match UIDs across the host/container boundary.
  sops.secrets."grafana-admin-password".mode = "0444";
  sops.secrets."grafana-secret-key".mode = "0444";
  # The ProtonVPN private key is decrypted here on the host by sops-nix so that
  # it can be bind-mounted read-only into the starr container, where the WireGuard
  # interface and network namespace are actually configured.
  sops.secrets."protonvpn-US-IL-503.key" = { };
}
