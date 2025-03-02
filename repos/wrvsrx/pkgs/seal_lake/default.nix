{
  source,
  stdenvNoCC,
  lib,
}:
stdenvNoCC.mkDerivation {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;
  installPhase = ''
    mkdir -p $out/share/$pname/cmake
    cp $pname.cmake $out/share/$pname/cmake/$pname-config.cmake
    cp CPM.cmake $out/share/$pname/cmake/CPM.cmake
  '';
}
