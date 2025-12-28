{
  stdenv,
  lib,
  source,
}:
stdenv.mkDerivation {
  inherit (source) pname src;
  version = "3.7.5-unstable-${source.date}";
  installPhase = ''
    mkdir -p $out/share
    cp -r . $out/share/noctalia-shell
  '';
}
