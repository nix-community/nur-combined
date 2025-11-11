{
  stdenv,
  lib,
  source,
}:
stdenv.mkDerivation {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;
  installPhase = ''
    mkdir -p $out/share
    cp -r . $out/share/noctalia-shell
  '';
}
