{ stdenv, lib, kaldi, openblas, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "libvosk";
  version = "0.3.32";

  src = (toString (fetchFromGitHub {
    # owner = "alphacep";

    # use my fork which has some NixOS fixes.
    owner = "nagy";
    repo = "vosk-api";
    rev = "524ef936edeaf7f609fba8a6a6ce22315d151f22";
    hash = "sha256-dJmmx094Vxs0t8Km472CjaeMsF2mjEhyBR1iwhF4xMg=";
  })) + "/src/";

  makeFlags = [ "PREFIX=$(out)" ];

  KALDI_ROOT = kaldi.outPath;

  OPENBLAS_ROOT = openblas.outPath;

  HAVE_OPENBLAS_CLAPACK = "0";

  meta = with lib; {
    description =
      "Offline speech recognition API for Android, iOS, Raspberry Pi and servers with Python, Java, C# and Node";
    homepage = "https://github.com/alphacep/vosk-api";
    license = with licenses; [ asl20 ];
  };
}
