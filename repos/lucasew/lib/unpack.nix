{ stdenvNoCC }:
{ src, patches ? [ ] }:
stdenvNoCC.mkDerivation {
  name = "source";
  inherit src patches;
  phases = [ "unpackPhase" "patchPhase" "installPhase" ];
  installPhase = ''
    cp -r . $out
  '';
}
