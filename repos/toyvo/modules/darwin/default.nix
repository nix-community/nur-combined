{ ... }:
{
  imports = [
    ./bash.nix
    ./homebrew.nix
    ./keyboard.nix
    ./ollama.nix
    ./podman.nix
    ./system.nix
    ./terminfo.nix
    ./touchid.nix
    ../os
  ];
}
