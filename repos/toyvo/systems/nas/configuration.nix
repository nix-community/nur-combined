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
    inputs.odysseus.nixosModules.default
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
    users.toyvo.programs.git.settings.safe.directory = "/mnt/POOL/hermes/*";
    users.hermes = {
      home.username = "hermes";
      home.homeDirectory = "/mnt/POOL/hermes";
      nixcfg = {
        shells.enable = true;
        tools.enable = true;
        session.enable = true;
        sops-home.enable = true;
        catppuccin-home.enable = true;
      };
      programs = {
        git = {
          enable = true;
          settings = {
            user.name = "Hermes Agent (${config.services.hermes-agent.settings.model.default} via ${config.services.hermes-agent.settings.model.provider}) for Collin Diekvoss";
            user.email = "hermes@diekvoss.com";
            safe.directory = "/home/toyvo/*";
            core.editor = lib.mkForce "hx";
          };
        };
        nvf.defaultEditor = lib.mkForce false;
        helix = {
          enable = true;
          defaultEditor = true;
        };
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
        fzf = {
          enable = true;
        };
      };
      home.packages = with pkgs; [
        ripgrep
        fd
        jq
        yq
        nix-output-monitor
        nix-tree
        gh
        tlrc
        procs
        dust
        sd
        hyperfine
      ];
    };
  };

  # Allow root (and libgit2 via nix) to access the flake repo for rebuilds
  environment.etc."gitconfig".text = ''
    [safe]
        directory = /home/toyvo/nixcfg
  '';
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
        9119 # hermes-dashboard
        8787 # hermes-webui
        7000 # odysseus
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
  nixcfg = {
    nix.enable = true;
    security.enable = true;
    home-manager.enable = true;
    networking.enable = true;
    system.enable = true;
    boot.enable = true;
    nix-ld.enable = true;
    gui.enable = true;
    dev.enable = true;
    users.hermes.enable = true;
  };
  userPresets.chloe.enable = true;
  userPresets.toyvo.enable = true;
  users.users.hermes = {
    uid = config.ids.uids.hermes;
    subUidRanges = [
      {
        startUid = 200000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 200000;
        count = 65536;
      }
    ];
  };
  users.groups.hermes.gid = config.ids.gids.hermes;
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
    odysseus = {
      enable = true;
      port = homelab.${hostName}.services.odysseus.port;
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
        host  authentik  authentik  10.200.0.0/16  scram-sha-256
      '';
    };
    protonmail-bridge.enable = true;
    samba.enable = true;
    spice-vdagentd.enable = true;
    monitoring.enable = true;
    syncthing = {
      enable = true;
      settings.folders."llm-wiki" = {
        path = "/mnt/POOL/hermes/wiki";
        id = "llm-wiki";
        label = "LLM Wiki";
        devices = [ ]; # Add devices manually via web UI after pairing
        versioning = {
          type = "simple";
          params.keep = "5";
        };
      };
    };
  };

  # Set authentik user password from sops secret at activation time
  systemd.services.postgresql.postStart = ''
    ${pkgs.postgresql_16}/bin/psql -tAc "ALTER ROLE authentik PASSWORD '$(cat ${
      config.sops.secrets."authentik-db-password".path
    })';"
  '';

  catppuccin = {
    enable = true;
    autoEnable = true;
  };
  nixcfg.containers = {
    open-webui = {
      enable = true;
      natInterface = "eno1";
      stateDir = "/mnt/POOL/open-webui";
      port = homelab.open-webui.services.open-webui.port;
      ollamaBaseUrl = "http://${homelab.MacMini-M1.ip}:${toString homelab.MacMini-M1.services.ollama.port}";
      environmentFile = config.sops.secrets."openwebui.env".path;
      environment = {
        # Hermes agent OpenAI-compatible API (host IP from container's perspective)
        OPENAI_API_BASE_URL = "http://${config.nixcfg.containers.open-webui.hostAddress}:8642/v1";
      };
    };
    immich = {
      enable = true;
      natInterface = "eno1";
      stateDir = "/mnt/POOL/immich";
      package = stablePkgs.immich;
    };
    jellyfin = {
      enable = true;
      natInterface = "eno1";
      stateDir = "/mnt/POOL/jellyfin";
      mediaDir = "/mnt/POOL/Public";
      plugins = [ inputs.nixcfg.packages.${system}.jellyfin-plugin-ldap-authentication ];
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
        host = config.nixcfg.containers.nextcloud.hostAddress;
        port = 1025;
        secure = "";
        username = "collin@diekvoss.com";
        passwordFile = config.sops.secrets."protonmail-bridge-smtp-password".path;
        fromAddress = "collin";
        domain = "diekvoss.com";
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
    authentik = {
      enable = true;
      natInterface = "eno1";
      db.passwordFile = config.sops.secrets."authentik-db-password".path;
      secretKeyFile = config.sops.secrets."authentik-secret-key".path;
      bootstrapPasswordFile = config.sops.secrets."authentik-bootstrap-password".path;
      ldap.tokenFile = config.sops.secrets."authentik-ldap-token".path;
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
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:1025,bind=${config.nixcfg.containers.nextcloud.hostAddress},fork,reuseaddr TCP:127.0.0.1:1025";
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
    git
    btop
    tree
    tmux
    pre-commit
    eza
    tldr
    python3
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
    hermes ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/nixos-container *
    hermes ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/journalctl *
    hermes ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/systemctl status *
    hermes ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/nixos-rebuild *
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
  services.hermes-dashboard = {
    enable = true;
    stateDir = "/mnt/POOL/hermes";
  };
  services.hermes-webui = {
    enable = true;
    stateDir = "/mnt/POOL/hermes";
  };
  services.hermes-agent = {
    enable = true;
    settings = {
      model = {
        # see https://models.dev/?search=opencode&sort=output-costper&order=asc if considering different models, same api key, but url is different https://opencode.ai/zen/v1 vs https://opencode.ai/zen/go/v1
        default = "kimi-k2.6";
        provider = "opencode-go";
        base_url = "https://opencode.ai/zen/go/v1";
        api_mode = "chat_completions";
      };
      toolsets = [ "hermes-cli" ];
      display.personality = "kawaii";
    };
    stateDir = "/mnt/POOL/hermes";
    environmentFiles = [ config.sops.secrets."hermes.env".path ];
    environment = {
      API_SERVER_HOST = "0.0.0.0";
      WIKI_PATH = "/mnt/POOL/hermes/wiki";
    };
    addToSystemPackages = true;
  };
  # Allow hermes-agent to use sudo for nixos-rebuild (upstream sets NoNewPrivileges=true)
  systemd.services.hermes-agent.serviceConfig.NoNewPrivileges = lib.mkForce false;

  # Expand PATH for hermes services so spawned terminals/shells have access to
  # system packages (nix, nixos-rebuild, git, etc.) and hermes's home-manager profile.
  # The upstream units hardcode PATH to only coreutils/findutils/gnugrep/gnused/systemd.
  # Appending a later Environment=PATH=... directive overrides the earlier one in systemd.
  systemd.services.hermes-agent.serviceConfig.Environment = [
    "PATH=/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/etc/profiles/per-user/hermes/bin:/mnt/POOL/hermes/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  ];
  systemd.services.hermes-webui.serviceConfig.Environment = [
    "PATH=/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/etc/profiles/per-user/hermes/bin:/mnt/POOL/hermes/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  ];

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
  sops.secrets."authentik-secret-key".mode = "0444";
  sops.secrets."authentik-bootstrap-password".mode = "0444";
  sops.secrets."authentik-ldap-token".mode = "0444";
  sops.secrets."authentik-db-password" = {
    owner = "postgres";
    mode = "0444";
  };
  # The ProtonVPN private key is decrypted here on the host by sops-nix so that
  # it can be bind-mounted read-only into the starr container, where the WireGuard
  # interface and network namespace are actually configured.
  sops.secrets."protonvpn-US-IL-503.key" = { };

  nix.settings.trusted-users = [
    "toyvo"
    "root"
    "hermes"
  ];

  # Set ACLs so container users can access external storage directories.
  # systemd-tmpfiles handles default ACLs (for new files); the apply-generated-acls
  # service recursively applies ACLs to existing files at boot.
  systemd.tmpfiles.generateRules = {
    # Mutual home access: hermes, toyvo, and chloe can access each other's homes.
    "/home/toyvo" = with config.ids.uids; [
      hermes
      toyvo
    ];
    "/home/chloe" = with config.ids.uids; [ chloe ];
    "/mnt/POOL/hermes" = with config.ids.uids; [
      hermes
      toyvo
    ];

    # Shared data directories.
    "/mnt/POOL/Chloe" = with config.ids.uids; [
      chloe
      nextcloud
    ];
    "/mnt/POOL/Collin" = with config.ids.uids; [
      nextcloud
      toyvo
      hermes
    ];
    "/mnt/POOL/Public" = with config.ids.uids; [
      bazarr
      chloe
      deluge
      hermes
      lidarr
      nextcloud
      prowlarr
      qbittorrent
      radarr
      readarr
      sonarr
      toyvo
      transmission
    ];

    # All starr users can access each other's subdirectories.
    "/mnt/POOL/starr" = with config.ids.uids; [
      bazarr
      deluge
      hermes
      lidarr
      prowlarr
      qbittorrent
      radarr
      readarr
      sonarr
      toyvo
      transmission
    ];

    # Service-specific directories.
    "/mnt/POOL/home-assistant" = with config.ids.uids; [
      hass
      toyvo
    ];
    "/mnt/POOL/immich" = with config.ids.uids; [
      immich
      toyvo
    ];
    "/mnt/POOL/jellyfin" = with config.ids.uids; [
      jellyfin
      toyvo
    ];
    "/mnt/POOL/nextcloud" = with config.ids.uids; [
      nextcloud
      toyvo
    ];
    "/mnt/POOL/open-webui" = with config.ids.uids; [
      open-webui
      toyvo
    ];
    "/mnt/POOL/authentik" = with config.ids.uids; [
      authentik
      toyvo
    ];
    "/mnt/POOL/authentik-redis" = with config.ids.uids; [
      authentik
      toyvo
    ];
  };
}
