let
  # Relative path to this location
  path = "./../../home-manager-modules";
  # List of home-manager modules we want for this system
  modules = [
    "bat"
    "direnv"
    "dircolours"
    "fzf"
    "jq"
    "git"
    "lsd"
    "starship"
    "vscodium"
    "zsh"
  ];
in {
  imports = (builtins.map (module: ./. + "${path}/${module}") modules)
    ++ [ ../../packages/linux.nix ];
}
