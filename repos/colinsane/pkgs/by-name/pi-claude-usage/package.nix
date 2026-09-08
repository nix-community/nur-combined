{
  lib,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "pi-claude-usage";
  version = "0.1.0";
  src = ./src;

  installPhase = ''
    mkdir -p $out
    cp index.ts $out/
  '';

  meta = {
    description = "Pi extension to add a /claude-usage command";
    maintainers = with lib.maintainers; [ colinsane ];
  };
}
