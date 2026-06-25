{ lib, self, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.cargoTOML = mkOption {
    description = "Current version of bun2nix";
    type = types.raw;
  };

  config.cargoTOML = builtins.fromTOML (builtins.readFile "${self}/programs/bun2nix/Cargo.toml");
}
