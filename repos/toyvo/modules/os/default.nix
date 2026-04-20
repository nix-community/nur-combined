{...}: {
  config.imports = [
    ./console.nix
    ./defaults.nix
    ./dev.nix
    ./gui.nix
    ./podman.nix
    ./users/chloe.nix
    ./users/root.nix
    ./users/toyvo.nix
  ];
}
