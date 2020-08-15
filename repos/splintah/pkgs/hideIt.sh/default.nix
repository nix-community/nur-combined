{ stdenv, lib, coreutils, gnused, xdotool, xev, xwininfo }:
let
  sources = import ../../nix/sources.nix;
in
stdenv.mkDerivation {
  pname = "hideIt.sh";
  version = sources."hideIt.sh".rev;
  src = sources."hideIt.sh";

  phases = [ "patchPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/hideIt.sh $out/bin/hideIt.sh
    patchShebangs $out/bin/hideIt.sh

    substituteInPlace $out/bin/hideIt.sh \
      --replace xdotool "${xdotool}/bin/xdotool" \
      --replace xev "${xev}/bin/xev" \
      --replace xwininfo "${xwininfo}/bin/xwininfo" \
      --replace sed "${gnused}/bin/sed" \
      --replace "seq " "${coreutils}/bin/seq "
    # NOTE: Replace "seq" followed by a space, because the file
    # contains the variable name "sequence".
  '';
}
