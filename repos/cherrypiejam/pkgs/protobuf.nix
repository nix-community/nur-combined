{ stdenv
, gnumake
, autoconf
, curl
, bzip2
, automake
, libtool
}:

stdenv.mkDerivation {
  pname = "protobuf";
  version = "2.5.0";

  src = builtins.fetchTarball {
    url = "https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.bz2";
    sha256 = "sha256:0p85zh97f35p700v7p7iyfik84cy1p97qkwgy0f566irqiwmb872";
  };

  nativeBuildInputs = [
    gnumake
    autoconf
    curl
    bzip2
    automake
    libtool
  ];

  configurePhase = ''
    ./configure --prefix=$out
  '';

  buildPhase = ''
    make -j
    make check
  '';

  installPhase = ''
    mkdir -p $out
    make install
  '';
}
