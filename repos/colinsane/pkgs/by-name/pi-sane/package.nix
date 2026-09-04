{
  lib,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "pi-sane";
  version = "0.1.0";
  src = ./src;

  installPhase = ''
    mkdir -p $out
    cp index.ts $out/
  '';

  meta = {
    description = "Pi extension for quality-of-life preferences";
    maintainers = with lib.maintainers; [ colinsane ];
  };
}
