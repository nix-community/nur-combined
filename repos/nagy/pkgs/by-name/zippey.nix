{
  lib,
  stdenv,
  fetchFromBitbucket,
  python3,
}:

stdenv.mkDerivation {
  pname = "zippey";
  version = "unstable-2014-05-28";

  src = fetchFromBitbucket {
    owner = "sippey";
    repo = "zippey";
    rev = "f037ce9e9b968fa053f95cd2804a248021ffcb41";
    hash = "sha256-kFHC1VDh8KI17owOcmOoGlW7v4oxpYYPrkvGuzC4XfA=";
  };

  buildInputs = [ python3 ];

  installPhase = ''
    runHook preInstall
    install -Dm755 zippey.py $out/bin/zippey
    install -Dm644 -t $out/share/doc/zippey README.md
    runHook postInstall
  '';

  meta = with lib; {
    description = "Git filter for friendly handling of ZIP-based files";
    homepage = "https://bitbucket.org/sippey/zippey/";
    license = licenses.free;
  };
}
