{
  stdenv,
  lib,
  source,
}:
stdenv.mkDerivation {
  inherit (source) pname src;
  # version = lib.removePrefix "v" source.version;
  version = "3.0.8-unstable-2025-11-11";
  installPhase = ''
    mkdir -p $out/share
    cp -r . $out/share/noctalia-shell
  '';
}
