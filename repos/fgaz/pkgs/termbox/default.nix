{ stdenv, fetchFromGitHub, python3 }:

stdenv.mkDerivation rec {
  name = "termbox";
  src = fetchFromGitHub {
    owner = "nsf";
    repo = "termbox";
    rev = "HEAD";
    sha256 = "06as1g26b77scvmq3anqndwjq74dzs4dq8vrl4g3vgdyjqxkk0d0";
  };
  nativeBuildInputs = [ python3 ];
  configurePhase = "python3 ./waf configure --prefix=$out";
  buildPhase = "python3 ./waf build";
  installPhase = "python3 ./waf install --destdir=$out";
}

