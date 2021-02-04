{ pkgs, fetchurl, stdenv }:
let
  buildFirefoxXpiAddon = { pname, url, sha256, ... }:
    pkgs.fetchFirefoxAddon { inherit url sha256; name = pname; };

  packages = with pkgs; import ./generated-addons.nix {
    inherit buildFirefoxXpiAddon fetchurl stdenv lib;
  };

  others = {
    "fx-cast" = pkgs.fetchFirefoxAddon {
      name = "fx_cast";
      url = "https://github.com/hensm/fx_cast/releases/download/v0.1.2/fx_cast-0.1.2-fx.xpi";
      sha256 = "1ibigm166b84p64vfs2kijs8g5y3y3dgbh54ifcg5lcbksjmmd1f";
    };
  };

in
others // packages // { inherit buildFirefoxXpiAddon; }
