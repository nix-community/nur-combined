# Makes the package set available as `pkgs.firefox-addons` and exposes the
# shared add-on builder as `pkgs.buildMozillaXpiAddon`.
final: prev:

let
  lib = import ../lib { pkgs = prev; };
in
{
  buildMozillaXpiAddon = lib.mozilla.mkBuildMozillaXpiAddon {
    inherit (final) fetchurl stdenv;
  };

  firefox-addons = import ../pkgs/firefox-addons { pkgs = final; };
}
