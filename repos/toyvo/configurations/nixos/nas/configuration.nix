{
  config,
  ekaPkgs,
  homelab,
  inputs,
  lib,
  pkgs,
  stablePkgs,
  system,
  unstablePkgs,
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
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nixos-unstable.nixosModules.notDetected
    inputs.nur.modules.nixos.default
    inputs.sops-nix.nixosModules.sops
  ];
  home-manager = {
    extraSpecialArgs = {
      inherit
        ekaPkgs
        inputs
        system
        homelab
        stablePkgs
        unstablePkgs
        ;
    };
    sharedModules = [ ./home.nix ];
    users.toyvo.programs.git.settings.safe.directory = "/mnt/POOL/agent/*";
    users.agent = {
      home.username = "agent";
      home.homeDirectory = "/mnt/POOL/agent";
      nixcfg = {
        shells.enable = true;
        session.enable = true;
        sops-home.enable = true;
      };
      programs = {
        git = {
          enable = true;
          settings = {
            user.name = "AI Agent (${config.services.hermes-agent.settings.model.default} via ${config.services.hermes-agent.settings.model.provider}) for Collin Diekvoss";
            user.email = "agent@diekvoss.com";
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
    # Resolve the cache domain via the router over LAN. The nas itself is
    # excluded from using it as a substituter (nixcfg.nix.excludeOwnCache),
    # but trusted users and CI can still pick it up from this flake's public
    # nixConfig, and the WAN path back in (hairpin) is broken.
    hosts."${homelab.router.ip}" = [ "cache.toyvo.dev" ];
    firewall = {
      allowedTCPPorts = [
        80
        53
        443
        5432
        8080
        3000 # forgejo
        8642 # hermes-agent API
        9119 # hermes-dashboard
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
    users.agent.enable = true;
  };
  userPresets.chloe.enable = true;
  userPresets.toyvo.enable = true;
  users.users.agent = {
    uid = config.ids.uids.agent;
    home = "/mnt/POOL/agent";
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
  users.groups.agent.gid = config.ids.gids.agent;
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
    # discord_bot = {
    #   enable = true;
    #   env_file = config.sops.secrets."discord_bot.env".path;
    #   env = {
    #     ADDR = "0.0.0.0";
    #     PORT = homelab.${hostName}.services.discord_bot.port;
    #     BASE_URL = "https://toyvo.dev";
    #   };
    # };
    forgejo = {
      enable = true;
      stateDir = "/mnt/POOL/forgejo";
      database.type = "postgres";
      settings = {
        server = {
          DOMAIN = "git.toyvo.dev";
          ROOT_URL = "https://git.toyvo.dev/";
          HTTP_PORT = homelab.${hostName}.services.forgejo.port;
        };
        # accounts are created by the admin via CLI, or log in via OAuth
        service.DISABLE_REGISTRATION = true;
        # global actions switch (already the forgejo default); each repo also
        # needs its Actions unit enabled: Repo Settings -> Actions
        actions.ENABLED = true;
      };
    };
    forgejo-runner = {
      instances.nas = {
        enable = true;
        settings.server.connections.default = {
          url = "https://git.toyvo.dev";
          # UUID of the runner created in the Forgejo UI (Site Administration
          # -> Actions -> Runners). Upstream offers no secrets-based uuid
          # option yet, so this lives in the world-readable store per
          # upstream's own migration; the token stays in sops.
          uuid = "7f299dbe-cc26-4902-9b6f-e4fb323875a6";
        };
        # File contains just the runner secret; the module loads it via
        # systemd LoadCredential and templates it into the daemon config.
        secrets.server.connections.default.token_url = config.sops.secrets."forgejo-runner-token-nas".path;
        settings.runner.labels = [
          # Jobs run directly on the host so builds share the system nix store.
          "native:host"
          "nix-latest:docker://nixos/nix"
        ];
        hostPackages = with pkgs; [
          bash
          cachix
          config.nix.package
          coreutils
          curl
          gawk
          git
          gnugrep
          gnused
          jq
          nodejs
          wget
        ];
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
    postgresql = {
      enable = true;
      enableTCPIP = true;
      authentication = lib.mkOverride 10 ''
        local all postgres         peer map=postgres
        local all all              peer
        host  all all 127.0.0.1/32 md5
        host  all all ::1/128      md5
        host  dioxus_music  dioxus_music  10.1.0.0/16  scram-sha-256
        host  discord_bot  discord_bot  10.1.0.0/16  scram-sha-256
        host  authentik  authentik  10.200.0.0/16  scram-sha-256
        host  authentik  authentik  10.1.0.0/16  scram-sha-256
      '';
    };
    protonmail-bridge.enable = true;
    samba.enable = true;
    spice-vdagentd.enable = true;
    monitoring.enable = true;
    syncthing = {
      enable = true;
      settings.folders."llm-wiki" = {
        path = "/mnt/POOL/agent/wiki";
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

  # Don't restart the runner on every nixos-rebuild switch: that SIGTERMs
  # running CI jobs with "ctx: context canceled, exec: RUN signal:
  # terminated". Restart it manually after changing its config. (This
  # doesn't cover the autoUpgrade reboot itself — the workflow schedule is
  # kept outside the 01:00-05:00 reboot window for that.)
  systemd.services.forgejo-runner-nas.restartIfChanged = false;

  # The new forgejo-runner module manages the .runner credentials file
  # itself from settings+secrets (DynamicUser, no registration step), so the
  # old ExecStartPre renderer is gone. If the runner is ever recreated in the
  # Forgejo UI, update the uuid above and the forgejo-runner-token-nas secret.

  # Set authentik user password from sops secret at activation time
  systemd.services.postgresql.postStart = lib.mkAfter ''
    ${config.services.postgresql.package}/bin/psql -tAc "ALTER ROLE authentik PASSWORD '$(cat ${
      config.sops.secrets."authentik-db-password".path
    })';"
  '';

  catppuccin = {
    enable = true;
    autoEnable = true;
  };
  nixcfg.containers = {
    immich = {
      enable = true;
      natInterface = "eno1";
      stateDir = "/mnt/POOL/immich";
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
    agent ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/nixos-container *
    agent ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/journalctl *
    agent ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/systemctl status *
    agent ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/nixos-rebuild *
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
  services.repo-maintainer = {
    enable = true;
    package = inputs.nixcfg.packages.${system}.repo-maintainer;
    stateDir = "/mnt/POOL/repo-maintainer";
    forgejoLogDir = "/mnt/POOL/forgejo/data/actions_log";
    environmentFile = config.sops.templates."repo-maintainer.env".path;
  };
  services.hermes-dashboard = {
    enable = true;
    stateDir = "/mnt/POOL/agent";
  };
  services.hermes-agent = {
    enable = true;
    settings = {
      model = {
        # see https://models.dev/?search=opencode&sort=output-costper&order=asc if considering different models, same api key, but url is different https://opencode.ai/zen/v1 vs https://opencode.ai/zen/go/v1
        default = "muse-spark-1.3-contributor";
        provider = "opencode-go";
        base_url = "https://opencode.ai/zen/go/v1";
        api_mode = "chat_completions";
      };
      toolsets = [ "hermes-cli" ];
      display.personality = "kawaii";
    };
    stateDir = "/mnt/POOL/agent";
    environmentFiles = [ config.sops.secrets."agent.env".path ];
    environment = {
      API_SERVER_HOST = "0.0.0.0";
      WIKI_PATH = "/mnt/POOL/agent/wiki";
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
    "PATH=/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/etc/profiles/per-user/agent/bin:/mnt/POOL/agent/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  ];

  # The runner's secret from the pre-created runner in the Forgejo UI (Site
  # Administration -> Actions -> Runners -> Create new runner). The template
  # wraps it into the TOKEN= env file used when rendering .runner credentials.
  sops.secrets."forgejo-runner-token-nas" = { };
  sops.secrets."agent.env".owner = "agent";
  # Maintainer shares the existing opencode key (owner call) and needs a
  # Forgejo PAT with repo scope: create it in the Forgejo UI, then add the
  # value with `sops secrets.yaml` under `repo-maintainer-forgejo-token`.
  # Until that key exists, do not deploy nas (activation will fail).
  sops.secrets."opencode_api_key" = { };
  sops.secrets."repo-maintainer-forgejo-token" = { };
  sops.templates."repo-maintainer.env".content = ''
    OPENCODE_GO_API_KEY=${config.sops.placeholder.opencode_api_key}
    FORGEJO_TOKEN=${config.sops.placeholder.repo-maintainer-forgejo-token}
  '';
  sops.secrets."signal-cli.env".owner = "signal-cli";
  sops.secrets."cache-priv-key.pem" = { };
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
    "agent"
  ];

  # Set ACLs so container users can access external storage directories.
  # systemd-tmpfiles handles default ACLs (for new files); the apply-generated-acls
  # service recursively applies ACLs to existing files at boot.
  systemd.tmpfiles.generateRules = {
    # Mutual home access: agent, toyvo, and chloe can access each other's homes.
    "/home/toyvo" = with config.ids.uids; [
      agent
      toyvo
    ];
    "/home/chloe" = with config.ids.uids; [ chloe ];
    "/mnt/POOL/agent" = with config.ids.uids; [
      agent
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
      agent
    ];
    "/mnt/POOL/Public" = with config.ids.uids; [
      bazarr
      chloe
      deluge
      agent
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
      agent
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
    "/mnt/POOL/authentik" = with config.ids.uids; [
      authentik
      toyvo
    ];
    "/mnt/POOL/authentik-redis" = with config.ids.uids; [
      authentik
      toyvo
    ];
  };
  zramSwap.enable = true;
  disko.devices = {
    disk.nvme0n1 = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            name = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              extraArgs = [
                "-n"
                "BOOT"
              ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [
                "-f"
                "-L"
                "NIXOS"
              ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                };
                "@home" = {
                  mountOptions = [ "compress=zstd" ];
                  mountpoint = "/home";
                };
                "@var" = {
                  mountOptions = [ "compress=zstd" ];
                  mountpoint = "/var";
                };
                "@nix" = {
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                  mountpoint = "/nix";
                };
              };
            };
          };
        };
      };
    };
    disk.sda = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          pool = {
            size = "100%";
            content = {
              device = "/dev/disk/by-label/POOL";
              type = "btrfs";
              extraArgs = [
                "-d"
                "raid1"
                "-m"
                "raid1"
                "/dev/sda"
                "/dev/sdb"
                "-f"
                "-L"
                "POOL"
              ];
              mountpoint = "/mnt/POOL";
              mountOptions = [
                "compress=zstd"
                "noatime"
              ];
            };
          };
        };
      };
    };
    disk.sdb = {
      type = "disk";
      device = "/dev/sdb";
    };
  };
}
