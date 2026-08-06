{
  # Add your Nix Darwin modules here
  #
  # my-module = ./my-module;
  default =
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
        (import ../os).default
      ];
    };
  bash = ./bash.nix;
  homebrew = ./homebrew.nix;
  keyboard = ./keyboard.nix;
  ollama = ./ollama.nix;
  podman = ./podman.nix;
  system = ./system.nix;
  terminfo = ./terminfo.nix;
  touchid = ./touchid.nix;
}
