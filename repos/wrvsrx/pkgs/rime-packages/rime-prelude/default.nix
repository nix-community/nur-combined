{
  stdenvNoCC,
  source,
}:
stdenvNoCC.mkDerivation {
  inherit (source) pname src;
  version = "0-unstable-" + source.date;
  installPhase = ''
    mkdir -p $out/share/rime-data/
    cp *.yaml $out/share/rime-data/
  '';
}
