{ pkgs, ... }: {
  imports = [
    ./dock.nix
    ./documentation.nix
    ./finder.nix
    ./homebrew.nix
    ./keyboard.nix
    ./login-window.nix
    ./ns-global-domain.nix
  ];
}
