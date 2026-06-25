{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) mkOption types;
in
{
  options.perSystem = mkPerSystemOption {
    options.mkDerivation.bun2nixNoOp = mkOption {
      description = ''
        `bun2nix` builds run the post-install script
        for their repos by default.

        However, the actual `bun2nix` binary is 
        unsuitable to be ran inside the nix sandbox,
        hence this package provides a no-op script with
        the same name to replace it.
      '';
      type = types.package;
    };
  };

  config.perSystem =
    { pkgs, ... }:
    {
      mkDerivation.bun2nixNoOp = pkgs.writeShellApplication {
        name = "bun2nix";
        text = "";
      };
    };
}
