{
  lib, stdenv,
  fetchFromGitHub,
  ...
} @ args:

stdenv.mkDerivation rec {
  pname = "route-chain";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "route-chain";
    rev = "b2068ce2905588f445ff95a05c00f200ec96d5b5";
    sha256 = "199y0mwn9q66mrclrx31hs4pz229im5wanab8pr4ngs2qiri6vh1";
  };

  enableParallelBuilding = true;

  installPhase = ''
    make install PREFIX=$out
  '';
}
