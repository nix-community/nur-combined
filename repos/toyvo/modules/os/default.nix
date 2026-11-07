{
  # Shared NixOS / nix-darwin modules, compatible with both.
  #
  # Import modules individually from system configurations, e.g.
  # `inputs.nixcfg.modules.os.nix`. Modules declare their own
  # dependent-module `imports`; configurations import only what they use.
  #
  # my-module = ./my-module;
  console = ./console.nix;
  dev = ./dev.nix;
  gui = ./gui.nix;
  home-manager = ./home-manager.nix;
  nix = ./nix.nix;
  odysseus = ./odysseus.nix;
  podman = ./podman.nix;
  security = ./security.nix;
  chloe = ./users/chloe.nix;
  agent = ./users/agent.nix;
  root = ./users/root.nix;
  toyvo = ./users/toyvo.nix;
}
