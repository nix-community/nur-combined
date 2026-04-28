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
    inputs.nixcfg.modules.nixos.default
    inputs.hermes-agent.nixosModules.default
    ./samba.nix
    ./homepage.nix
    inputs.catppuccin.nixosModules.catppuccin
    inputs.dioxus_monorepo.nixosModules.discord_bot
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.default
    inputs.nh.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nixos-unstable.nixosModules.notDetected
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
        8642 # hermes-agent API (reachable from open-webui container via veth)
      ];
      allowedUDPPorts = [
        53
        443
        8080
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
      enable = true;
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
    protonmail-bridge.enable = true;
    samba.enable = true;
    spice-vdagentd.enable = true;
    monitoring.enable = true;
  };
  containerPresets = {
    open-webui = {
      enable = true;
      natInterface = "eno1";
      stateDir = "/mnt/POOL/open-webui";
      port = homelab.open-webui.services.open-webui.port;
      ollamaBaseUrl = "http://${homelab.MacMini-M1.ip}:${toString homelab.MacMini-M1.services.ollama.port}";
      environmentFile = config.sops.secrets."openwebui.env".path;
      environment = {
        # Hermes agent OpenAI-compatible API (host IP from container's perspective)
        OPENAI_API_BASE_URL = "http://${config.containerPresets.open-webui.hostAddress}:8642/v1";
      };
    };
    immich = {
      enable = true;
      natInterface = "eno1";
      stateDir = "/mnt/POOL/immich";
      package = stablePkgs.immich;
      immichUid = 354;
    };
    jellyfin = {
      enable = true;
      natInterface = "eno1";
      stateDir = "/mnt/POOL/jellyfin";
      mediaDir = "/mnt/POOL/Public";
    };
    nextcloud = {
      enable = true;
      natInterface = "eno1";
      stateDir = "/mnt/POOL/nextcloud";
      mediaDir = "/mnt/POOL";
      nextcloudAdminPasswordFile = config.sops.secrets."nextcloud_admin_password".path;
      package = pkgs.nextcloud33;
      extraAppNames = [
        "bookmarks"
        "calendar"
        "contacts"
        "cookbook"
        "mail"
        "music"
        "notes"
        "richdocuments"
        "tasks"
      ];
      smtp = {
        host = config.containerPresets.nextcloud.hostAddress;
        port = 1025;
        secure = "";
        username = "collin@diekvoss.com";
        passwordFile = config.sops.secrets."protonmail-bridge-smtp-password".path;
        fromAddress = "nextcloud";
        domain = "diekvoss.net";
      };
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
      natInterface = "eno1";
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
  # Relay the bridge's localhost-only SMTP port to the nextcloud container's veth address.
  # The bridge listens on 127.0.0.1:1025; socat forwards connections from the container.
  systemd.services.protonmail-bridge-relay = {
    description = "Relay protonmail-bridge SMTP to nextcloud container";
    after = [
      "network.target"
      "protonmail-bridge.service"
    ];
    wants = [ "protonmail-bridge.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:1025,bind=${config.containerPresets.nextcloud.hostAddress},fork,reuseaddr TCP:127.0.0.1:1025";
      Restart = "on-failure";
      RestartSec = "5s";
      DynamicUser = true;
    };
  };

  networking.firewall.interfaces."ve-nextcloud".allowedTCPPorts = [ 1025 ];

  fileSystems."/mnt/POOL" = {
    device = "/dev/disk/by-label/POOL";
    fsType = "btrfs";
  };
  users.users.toyvo.extraGroups = [ "libvirtd" ];
  home-manager.users.toyvo.programs.beets.settings.directory = "/mnt/POOL/Public/Music";
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    # bottles
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
    signal-cli
  ];
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
    spiceUSBRedirection.enable = true;
  };
  security.sudo.extraConfig = ''
    %wheel ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/nixos-container *
    %wheel ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/journalctl *
    %wheel ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/systemctl status *
  '';

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };
  services.signal-cli = {
    enable = true;
    environmentFile = config.sops.secrets."signal-cli.env".path;
  };
  services.hermes-agent = {
    enable = true;
    settings = {
      model = {
        default = "glm-5";
        provider = "opencode-go";
        base_url = "https://opencode.ai/zen/go/v1";
        api_mode = "chat_completions";
      };
      toolsets = [ "hermes-cli" ];
      display.personality = "kawaii";
    };
    stateDir = "/mnt/POOL/hermes";
    environmentFiles = [ config.sops.secrets."hermes.env".path ];
    environment.API_SERVER_HOST = "0.0.0.0";
    addToSystemPackages = true;
  };
  sops.secrets."hermes.env".owner = "hermes";
  sops.secrets."signal-cli.env".owner = "signal-cli";
  sops.secrets."cache-priv-key.pem" = { };
  sops.secrets."discord_bot.env" = {
    owner = "discord_bot";
    group = "discord_bot";
  };
  # Grafana credentials are bind-mounted into the monitoring container where the grafana user
  # reads them via $__file{}. mode 0444 allows any process (including container-side grafana) to
  # read them without needing to match UIDs across the host/container boundary.
  # Nextcloud admin password bind-mounted into the nextcloud container; mode 0444 so
  # the nextcloud user inside the container can read it without UID alignment on the host.
  sops.secrets."openwebui.env".mode = "0444";
  sops.secrets."nextcloud_admin_password".mode = "0444";
  # Bridge generates a random per-account SMTP password on first login; store it here after setup.
  sops.secrets."protonmail-bridge-smtp-password".mode = "0444";
  sops.secrets."grafana-admin-password".mode = "0444";
  sops.secrets."grafana-secret-key".mode = "0444";
  # The ProtonVPN private key is decrypted here on the host by sops-nix so that
  # it can be bind-mounted read-only into the starr container, where the WireGuard
  # interface and network namespace are actually configured.
  sops.secrets."protonvpn-US-IL-503.key" = { };

  # Set ACLs so container users can access external storage directories.
  # These are applied at boot time by systemd-tmpfiles.
  systemd.tmpfiles.rules = [
    # Nextcloud user (UID 993) - needs rwx for external storage (upload/modify files)
    "a /mnt/POOL/Public - - - - u:993:rwx"
    "a /mnt/POOL/Collin - - - - u:993:rwx"
    "a /mnt/POOL/Chloe - - - - u:993:rwx"
    "A /mnt/POOL/Public - - - - u:993:rwx"
    "A /mnt/POOL/Collin - - - - u:993:rwx"
    "A /mnt/POOL/Chloe - - - - u:993:rwx"

    # Starr services - need rwx for downloading and organizing media
    # Multimedia group (GID 349) - used by most *arr services
    "a /mnt/POOL/Public - - - - g:349:rwx"
    "A /mnt/POOL/Public - - - - g:349:rwx"
    # Individual starr service UIDs for explicit access
    "a /mnt/POOL/Public - - - - u:350:rwx" # bazarr
    "a /mnt/POOL/Public - - - - u:351:rwx" # prowlarr
    "a /mnt/POOL/Public - - - - u:352:rwx" # readarr
    "a /mnt/POOL/Public - - - - u:353:rwx" # qbittorrent
    "A /mnt/POOL/Public - - - - u:350:rwx" # bazarr
    "A /mnt/POOL/Public - - - - u:351:rwx" # prowlarr
    "A /mnt/POOL/Public - - - - u:352:rwx" # readarr
    "A /mnt/POOL/Public - - - - u:353:rwx" # qbittorrent
  ];
}
