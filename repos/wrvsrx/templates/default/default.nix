{ stdenvNoCC }:
stdenvNoCC.mkDerivation {
  name = "";
  src = ./.;
  nativeBuildInputs = [ ];
  installPhase = ''
    mkdir -p $out
  '';
}
