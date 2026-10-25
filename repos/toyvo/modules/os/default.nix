{
  # Add your NixOS / Nix Darwin modules here, should be compatible with both
  #
  # my-module = ./my-module;
  default =
    { ... }:
    {
      imports = [
        ./console.nix
        ./dev.nix
        ./gui.nix
        ./home-manager.nix
        ./nix.nix
        ./odysseus.nix
        ./podman.nix
        ./security.nix
        ./users/chloe.nix
        ./users/agent.nix
        ./users/root.nix
        ./users/toyvo.nix
      ];
    };
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
