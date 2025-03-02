{
  stdenv,
  cmake,
  source,
  lib,
}:
stdenv.mkDerivation {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;
  nativeBuildInputs = [ cmake ];
}
