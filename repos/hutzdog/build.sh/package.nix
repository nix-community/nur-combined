{ lib, stdenv, fetchgit, pandoc }:

stdenv.mkDerivation rec {
  pname = "build.sh";
  version = "1.0.0";

  src = fetchgit {
    url = "https://git.sr.ht/~hutzdog/build.sh";
    rev = "c8318cdc5c92e5e5d6fc9227c7c3c960cdffe480";
    sha256 = "0zwny6i8wl7qg6d8c558rxs7kv9mfkql34p7i63w20xn1aii56ha";
  };

  buildInputs = [ pandoc ];

  buildPhase=''
    bash $src/src/build.sh build $src
  '';

  installPhase=''
    mkdir -p $out
    bash src/build.sh install $src $out
  '';

  meta = with lib; {
    description = "A <100 line pure Bash build system.";
    homepage = "https://sr.ht/~hutzdog/build.sh";
    license = licenses.bsd3;
    platforms = platforms.all;
  };
}
