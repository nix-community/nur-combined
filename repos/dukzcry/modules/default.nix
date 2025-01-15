rec {
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  logitech-k380 = ./logitech-k380.nix;
  hidpi = ./hidpi.nix;
  jack = ./jack.nix;
  pulseaudio = ./pulseaudio.nix;
  pipewire = ./pipewire.nix;
  bambootracker = ./bambootracker.nix;
  nvidia = ./nvidia.nix;
  job = ./job.nix;
  monitor = ./monitor.nix;
  server = ./server.nix;
  headless = ./headless.nix;
  regdomain = ./regdomain.nix;
  blacklist = ./blacklist.nix;
  hardware = ./hardware.nix;
  tun2socks = ./tun2socks.nix;
  cockpit = ./cockpit.nix;
  gamescope = ./gamescope.nix;
  vscodium = ./vscodium.nix;
  udisks = ./udisks.nix;
  local-variables = ./local-variables.nix;
  gaming = ./gaming.nix;
  theme = ./theme.nix;
  sunpaper = ./sunpaper.nix;
  jellyfin = ./jellyfin.nix;
  metube = ./metube.nix;
  catppuccin = ./catppuccin.nix;
  zsh = ./zsh.nix;
  branding = ./branding.nix;
  sd-cpp-webui = ./sd-cpp-webui.nix;
  dashboard = ./dashboard.nix;
  watchyourlan = ./watchyourlan.nix;
}
