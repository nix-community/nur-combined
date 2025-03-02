{ stdenvNoCC, source }:
stdenvNoCC.mkDerivation {
  inherit (source) pname src;
  version = "0-unstable-" + source.date;
  installPhase = ''
    mkdir -p $out/freshapi
    cp -r api init.php $out/freshapi
  '';
}
