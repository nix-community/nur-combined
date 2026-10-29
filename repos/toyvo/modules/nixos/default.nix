{
  # NixOS modules, importable individually from system configurations,
  # e.g. `inputs.nixcfg.modules.nixos.boot`. Modules declare their own
  # dependent-module `imports`; configurations import only what they use.
  #
  # my-module = ./my-module;
  authentik_container = ./containers/authentik.nix;
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
  odysseus = ./odysseus.nix;
  system = ./system.nix;
  ids = ./ids.nix;
  k3s = ./k3s.nix;
  k3s-homepage = ./k3s-homepage.nix;
  k3s-homeassistant = ./k3s-homeassistant.nix;
  k3s-storage = ./k3s-storage.nix;
  k3s-starr = ./k3s-starr.nix;
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
  repo-maintainer = ./services/repo-maintainer.nix;
  signal-cli = ./services/signal-cli.nix;
  syncthing = ./syncthing.nix;
  tmpfiles = ./tmpfiles.nix;
  vintagestory = ./vintagestory.nix;
}
