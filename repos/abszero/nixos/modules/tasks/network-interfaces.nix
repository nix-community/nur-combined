{ lib, ... }:

let
  inherit (lib) types mkOption;
in

{
  options.abszero.networking.addrs = mkOption {
    type =
      with types;
      attrsOf (
        submodule (
          { name, ... }: {
            options = {
              addr = mkOption {
                type = types.singleLineStr;
                default = name;
              };
              type = mkOption {
                type = types.enum [
                  "ipv4"
                  "ipv6"
                ];
                default = "ipv4";
              };
            };
          }
        )
      );
    default = { };
    description = "List of addresses of the host";
  };
}
