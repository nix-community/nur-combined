# This configuration file simply determines the hostname and then import both
# the default configuration (common for all machine) and specific machine
# configuration.
let
  hostName = "${builtins.readFile ./hostname}";
in
{
  imports = [
    # Generated hardware configuration
    ./hardware-configuration.nix
    # Default profile with default configuration
    ./modules/module-list.nixos.nix
    # Set the machine to nixos
    ./machines/is-nixos.nix
    # Machine specific configuration files
    (./machines + "/${hostName}.nixos.nix")
  ];

  networking.hostName = "${hostName}";
}
