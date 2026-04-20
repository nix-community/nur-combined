{ ... }:
{
  imports = [
    ./defaults.nix
    ./ollama.nix
    ./podman.nix
    ../os
  ];
}
