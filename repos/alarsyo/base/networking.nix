{lib, ...}: let
  inherit
    (lib)
    mkOption
    types
    ;
in {
  options.my.networking.externalInterface = mkOption {
    type = types.nullOr types.str;
    default = null;
    example = "eth0";
    description = ''
      Name of the network interface that egresses to the internet. Used for
      e.g. NATing internal networks.
    '';
  };
}
