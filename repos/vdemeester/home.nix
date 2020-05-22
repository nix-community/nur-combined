# This configuration file simply determines the hostname and then import both
# the default configuration (common for all machine) and specific machine
# configuration.
let
  hostName = "${builtins.readFile ./hostname}";
in
{
  imports = [
    # Default profile with default configuration
    ./modules/module-list.nix
    # Set the machine to home
    ./machines/is-hm.nix
    # Machine specific configuration files
    (./machines + "/${hostName}.nix")
  ];
}
