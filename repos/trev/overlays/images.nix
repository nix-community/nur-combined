{ }:
_: prev:
let
  images = import ../images {
    system = prev.stdenv.buildPlatform.system;
    pkgs = prev;
  };
in
{
  image = images;
}
