# This configuration file simply determines the hostname and then import both
# the default configuration (common for all machine) and specific machine
# configuration.
let
  hostName = "${builtins.readFile ./hostname}";
  home-manager = (import ./nix/sources.nix).home-manager;
in
{
  programs = {
    home-manager = {
      enable = true;
      path = "${home-manager}";
    };
  };
  nixpkgs.overlays = [
    (import ./overlays/sbr.nix)
    (import ./overlays/unstable.nix)
    (import ./nix).emacs
  ];
  imports = [
    # Default profile with default configuration
    ./modules/module-list.nix
    # Set the machine to home
    ./machines/is-hm.nix
    # Machine specific configuration files
    (./machines + "/${hostName}.nix")
  ];
}
