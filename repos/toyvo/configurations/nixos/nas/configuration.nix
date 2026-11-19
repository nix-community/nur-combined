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
    inputs.nixcfg.modules.os.nix
    inputs.nixcfg.modules.os.security
    inputs.nixcfg.modules.os.home-manager
    inputs.nixcfg.modules.os.podman
    inputs.nixcfg.modules.os.toyvo
    inputs.nixcfg.modules.os.chloe
    inputs.nixcfg.modules.os.root
    inputs.nixcfg.modules.os.agent
    inputs.nixcfg.modules.nixos.ids
    inputs.nixcfg.modules.nixos.boot
    inputs.nixcfg.modules.nixos.networking
    inputs.nixcfg.modules.nixos.system
    inputs.nixcfg.modules.nixos.nix-ld
    inputs.nixcfg.modules.nixos.podman
    inputs.nixcfg.modules.nixos.k3s
    inputs.nixcfg.modules.nixos.k3s-edge
    inputs.nixcfg.modules.nixos.k3s-homepage
    inputs.nixcfg.modules.nixos.k3s-homeassistant
    inputs.nixcfg.modules.nixos.k3s-immich
    inputs.nixcfg.modules.nixos.k3s-jellyfin
    inputs.nixcfg.modules.nixos.k3s-nextcloud
    inputs.nixcfg.modules.nixos.k3s-office
    inputs.nixcfg.modules.nixos.k3s-authentik
    inputs.nixcfg.modules.nixos.k3s-monitoring
    inputs.nixcfg.modules.nixos.k3s-storage
    inputs.nixcfg.modules.nixos.k3s-starr
    inputs.nixcfg.modules.nixos.monitoring
    inputs.nixcfg.modules.nixos.ollama
    inputs.nixcfg.modules.nixos.protonmail-bridge
    inputs.nixcfg.modules.nixos.repo-maintainer
    inputs.nixcfg.modules.nixos.signal-cli
    inputs.nixcfg.modules.nixos.syncthing
    inputs.nixcfg.modules.nixos.tmpfiles
    inputs.hermes-agent.nixosModules.default
    ./samba.nix
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
    users.agent.home.homeDirectory = lib.mkForce "/mnt/POOL/agent";
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
        2049 # NFSv4 for k3s shared storage
        4001 # lockd (fixed port, deterministic firewall)
        4002 # mountd (fixed port, deterministic firewall)
        4003 # statd (fixed port, deterministic firewall)
        1025 # protonmail-bridge SMTP relay (LAN-bound for k3s nextcloud; bridge enforces SMTP AUTH)
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
    k3s = {
      enable = true;
      role = "server";
      traefik.enable = true;
      clusterInit = true;
      tokenFile = config.sops.secrets."k3s-token".path;
      extraSANs = [
        "10.1.0.3"
        "nas"
        "nas.diekvoss.net"
        "10.1.0.1"
        "10.1.0.6"
        "10.1.0.12"
      ];
    };
    # First migration passenger; manifests deploy cluster-wide from here.
    k3sHomepage.enable = true;
    # Traefik edge routes generated from homelab.
    k3sEdge.enable = true;
    # Home Assistant (not starr); same cluster-wide pattern.
    k3sHomeassistant.enable = true;
    # Immich (server + ML + Postgres + Valkey, live since 2026-11-14 cutover).
    k3sImmich.enable = true;
    # Jellyfin (official image, UID 359, DRI passthrough); replicas 1 from
    # the start (cold sqlite seed + RO media = no shared-state hazard).
    k3sJellyfin.enable = true;
    # Euro-Office Document Server (all-in-one image, JWT-secured, no
    # forward-auth); greenfield, nothing to retire.
    k3sOffice.enable = true;
    # Nextcloud core (official image, UID 360, bundled Postgres + cron
    # sidecar, Collabora dropped); replicas 1 from the start (fresh empty
    # DB + state pre-flip, edge still routes to the container).
    k3sNextcloud.enable = true;
    # Monitoring stack (Grafana + Prometheus + Loki + Tempo); backends seed
    # from the container's private state at Task 4 (POOL copies are stale).
    k3sMonitoring.enable = true;

    # Authentik SSO in k3s (server + worker/beat + LDAP outpost + redis);
    # file state is empty (everything real lives in host Postgres), so
    # the stack starts fresh-empty. THE FLIP (forwardAuth address) is a
    # separate attended switch — see plan Task 6.
    k3sAuthentik.enable = true;

    # Shared NFS storage (csi-driver-nfs + static pool PVs).
    # Single writer: enable ONLY here, never on another server.
    k3sStorage.enable = true;
    # First starr migration; manifests deploy cluster-wide from here.
    k3sStarr.prowlarr.enable = true;
    # Second starr migration (sonarr); same template + RW media mount.
    k3sStarr.sonarr.enable = true;
    # Third starr migration (lidarr); same template again.
    k3sStarr.lidarr.enable = true;
    # Fourth starr migration (radarr); same template again.
    k3sStarr.radarr.enable = true;
    # Fifth starr migration (readarr); same template again.
    k3sStarr.readarr.enable = true;
    # Sixth starr migration (bazarr); same template, different wiring.
    k3sStarr.bazarr.enable = true;
    # Stateless solver for prowlarr; no storage at all.
    k3sStarr.flaresolverr.enable = true;
    # Last one: VPN-isolated torrent client.
    k3sStarr.qbittorrent.enable = true;
    security.enable = true;
    home-manager.enable = true;
    networking.enable = true;
    system.enable = true;
    boot.enable = true;
    nix-ld.enable = true;
    gui.enable = true;
    dev.enable = true;
    users = {
      agent.enable = true;
      chloe.enable = true;
      root.enable = true;
      toyvo.enable = true;
    };
  };
  users.users.agent.home = lib.mkForce "/mnt/POOL/agent";
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
        # k3s pods (server/worker) reach Postgres with pod IPs (10.42/16,
        # no SNAT on this path — proven by the 10.42.0.94 pg_hba rejection).
        host  authentik  authentik  10.42.0.0/16  scram-sha-256
      '';
    };
    protonmail-bridge.enable = true;
    samba.enable = true;
    nfs.server = {
      enable = true;
      # Fixed ports so the firewall stays deterministic (v4-only traffic,
      # single port 2049 in practice).
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4003;
      createMountPoints = true;
      exports = ''
        /mnt/POOL/k3s-test 10.1.0.0/24(rw,sync,no_subtree_check,root_squash)
        # RW: sonarr (and future *arrs) import into the library here.
        # Pod-level read-only is still enforced separately via the
        # pool-public-ro PV (mountOptions ro + csi.readOnly).
        /mnt/POOL/Public 10.1.0.0/24(rw,sync,no_subtree_check,root_squash)
        # RW: k8s immich-server mounts the photo library here at /data.
        /mnt/POOL/immich/library 10.1.0.0/24(rw,sync,no_subtree_check,root_squash)
        # RW: k8s nextcloud external-storage mounts (verified local mounts).
        /mnt/POOL/Collin 10.1.0.0/24(rw,sync,no_subtree_check,root_squash)
        /mnt/POOL/Chloe 10.1.0.0/24(rw,sync,no_subtree_check,root_squash)
      '';
    };
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

  # Cap runner memory so a future blowup fails the job instead of letting
  # the kernel OOM-kill the whole unit and starve postgres/forgejo (seen
  # 2026-10-25: 18 GB mem + 12 GB swap peak). Headroom above the ~19 GB
  # single-evaluation peak on a 31 GB + 15 GB-zram box.
  systemd.services.forgejo-runner-nas.serviceConfig.MemoryHigh = "26G";
  systemd.services.forgejo-runner-nas.serviceConfig.MemoryMax = "28G";

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
  # Relay the bridge's localhost-only SMTP port to the LAN for the k8s
  # Nextcloud pod (pods can't reach a container veth). The veth relay was
  # removed with the retired container; the bridge itself enforces SMTP
  # AUTH, so a LAN-bound relay is not an open relay.
  systemd.services.protonmail-bridge-relay-lan = {
    description = "Relay protonmail-bridge SMTP to LAN for k3s nextcloud";
    after = [
      "network.target"
      "protonmail-bridge.service"
    ];
    wants = [ "protonmail-bridge.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:1025,bind=10.1.0.3,fork,reuseaddr TCP:127.0.0.1:1025";
      Restart = "on-failure";
      RestartSec = "5s";
      DynamicUser = true;
    };
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
    # TEMPORARY DEBUG: passwordless k3s for faster agent-driven diagnostics.
    %wheel ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/k3s *
    %wheel ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/kubectl *
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
  services.hermes-agent = {
    enable = true;
    user = "agent";
    group = "agent";
    createUser = false;
    # Built-in dashboard backend (replaces the old custom services.hermes-dashboard
    # module, which passed the now-dead `--insecure` flag). Runs
    # `hermes dashboard --host 0.0.0.0 --port 9119` as hermes-backend.service.
    # A non-loopback bind engages the dashboard auth gate, satisfied below by
    # native OIDC against Authentik (self-hosted provider).
    backend = {
      mode = "dashboard";
      host = "0.0.0.0";
      port = homelab.${hostName}.services.hermes_dashboard.port;
    };
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
      dashboard = {
        # Public URL behind the router Traefik edge. Its hostname is
        # trusted by the Host/Origin guards and it builds the OIDC
        # redirect_uri (https://hermes.diekvoss.net/auth/callback).
        public_url = "https://hermes.diekvoss.net";
        # Trust X-Forwarded-Proto/-Host from the router reverse proxy.
        trusted_proxies = [ homelab.router.ip ];
        oauth.self_hosted = {
          issuer = "https://auth.diekvoss.net/application/o/hermes/";
          # Client ID from the Authentik OAuth2/OIDC provider (slug
          # hermes). Fill in after creating it in the Authentik UI.
          client_id = "2YLxUNkZnHxrwSK2LzpeQ4YUUv1UkIOcODQmAcRQ";
          scopes = "openid profile email";
        };
      };
    };
    stateDir = "/mnt/POOL/agent";
    # agent.env must also export HERMES_DASHBOARD_OIDC_CLIENT_SECRET (the
    # confidential-client secret from the Authentik provider); env wins over
    # config.yaml and keeps the secret out of the world-readable store.
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
  sops.secrets."k3s-token" = { };
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

  };
  # The repo checkout: keep file ACLs VCS-clean between boots (new files
  # are born without default ACLs; the 5-minute timer re-asserts entries).
  # Scoped to the checkout only — never list media trees here (see option).
  systemd.tmpfiles.generateRulesContinuous = {
    "/home/toyvo/nixcfg" = with config.ids.uids; [
      agent
      toyvo
    ];
  };
  systemd.tmpfiles.generateRules = {
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
