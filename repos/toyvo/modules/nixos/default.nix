{
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  default =
    { ... }:
    {
      imports = [
        (import ../os).default
        ./containers/authentik.nix
        ./containers/home-assistant.nix
        ./containers/immich.nix
        ./containers/jellyfin.nix
        ./containers/minecraft.nix
        ./containers/monitoring.nix
        ./containers/nextcloud.nix
        ./containers/open-webui.nix
        ./containers/starr.nix
        ./containers/terraria.nix
        ./containers/vintagestory.nix
        ./boot.nix
        ./kanata.nix
        ./networking.nix
        ./nix-ld.nix
        ./system.nix
        ./ids.nix
        ./filesystems.nix
        ./gaming.nix
        ./mcsmanager.nix
        ./monitoring/default.nix
        ./monitoring/grafana.nix
        ./monitoring/internet.nix
        ./monitoring/loki.nix
        ./monitoring/prometheus.nix
        ./monitoring/tempo.nix
        ./podman.nix
        ./services/desktopManager/cosmic.nix
        ./services/desktopManager/gnome.nix
        ./services/desktopManager/plasma.nix
        ./services/desktopManager/xfce.nix
        ./services/minecraft.nix
        ./services/ollama.nix
        ./services/protonmail-bridge.nix
        ./services/hermes-dashboard.nix
        ./services/hermes-webui.nix
        ./services/signal-cli.nix
        ./syncthing.nix
        ./tmpfiles.nix
        ./vintagestory.nix
      ];
    };
  authentik_container = ./containers/authentik.nix;
  home-assistant_container = ./containers/home-assistant.nix;
  immich_container = ./containers/immich.nix;
  jellyfin_container = ./containers/jellyfin.nix;
  minecraft_container = ./containers/minecraft.nix;
  monitoring_container = ./containers/monitoring.nix;
  nextcloud_container = ./containers/nextcloud.nix;
  open-webui_container = ./containers/open-webui.nix;
  starr_container = ./containers/starr.nix;
  terraria_container = ./containers/terraria.nix;
  vintagestory_container = ./containers/vintagestory.nix;
  boot = ./boot.nix;
  kanata = ./kanata.nix;
  networking = ./networking.nix;
  nix-ld = ./nix-ld.nix;
  system = ./system.nix;
  ids = ./ids.nix;
  filesystems = ./filesystems.nix;
  gaming = ./gaming.nix;
  mcsmanager = ./mcsmanager.nix;
  monitoring = ./monitoring/default.nix;
  grafana = ./monitoring/grafana.nix;
  internet = ./monitoring/internet.nix;
  loki = ./monitoring/loki.nix;
  prometheus = ./monitoring/prometheus.nix;
  tempo = ./monitoring/tempo.nix;
  podman = ./podman.nix;
  cosmic = ./services/desktopManager/cosmic.nix;
  gnome = ./services/desktopManager/gnome.nix;
  plasma = ./services/desktopManager/plasma.nix;
  xfce = ./services/desktopManager/xfce.nix;
  minecraft = ./services/minecraft.nix;
  ollama = ./services/ollama.nix;
  protonmail-bridge = ./services/protonmail-bridge.nix;
  hermes-dashboard = ./services/hermes-dashboard.nix;
  hermes-webui = ./services/hermes-webui.nix;
  signal-cli = ./services/signal-cli.nix;
  syncthing = ./syncthing.nix;
  tmpfiles = ./tmpfiles.nix;
  vintagestory = ./vintagestory.nix;
}
