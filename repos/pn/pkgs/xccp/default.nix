{ stdenv, fetchFromGitHub, libX11 }:
stdenv.mkDerivation {
  name = "xccp";

  src = fetchFromGitHub {
    repo = "xccp";
    owner = "hohmannr";
    rev = "42dac1a6cd7b0ba779c1770664e003371400c1f8";
    sha256 = "1yw0g97r2irzbnwl6kj5p8f8s1iylm7yazfbi1kwhk55fazczq1v";
  };

  buildInputs = [ libX11 ];
  buildPhase = "make CC=${stdenv.cc}/bin/gcc";
  installPhase = "make install INSTALL_DIR=$out/bin";
}
