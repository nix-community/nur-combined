{ lib, ... }:

let
  inherit (lib) filter;
  inherit (builtins) attrValues;
in

{
  perSystem = { pkgs, ... }: rec {
    checks.buildPackages = pkgs.stdenv.mkDerivation {
      name = "all-packages";
      buildInputs = filter
        (pkg: pkg ? meta.broken -> !pkg.meta.broken)
        (attrValues packages);
      dontUnpack = true;
      installPhase = ''mkdir -p $out'';
    };
    packages = import ./. { inherit pkgs; };
  };
  flake.overlays = rec {
    abszero = final: _: import ./. { pkgs = final; };
    default = abszero;
  };
}
