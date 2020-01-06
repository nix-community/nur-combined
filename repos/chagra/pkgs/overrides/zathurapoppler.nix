{ zathura, stdenv, makeWrapper }:
let
  zathura-override = (zathura.override { useMupdf = false; });
in

stdenv.mkDerivation {
  name="zathura-poppler-only";
  dontUnpack=true;
  dontInstall=true;
  buildInputs = [ makeWrapper ];
  buildPhase = ''
    makeWrapper ${zathura-override}/bin/zathura $out/bin/zathura-poppler-only
  '';
}
