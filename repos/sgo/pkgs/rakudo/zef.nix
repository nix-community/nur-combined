{ stdenv, fetchFromGitHub, rakudo, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "zef";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "ugexe";
    repo = "zef";
    rev = "v${version}";
    sha256 = "064nbl2hz55mpxdcy9zi39s2z6bad3bj73xsna966a7hzkls0a70";
  };

  buildInputs = [ rakudo makeWrapper ];

  # postPatch = ''
  #   #substituteInPlace resources/config.json \
  #   #  --replace '$*HOME' "$TMPDIR"
  # '';

  installPhase = ''
    set -ex
    mkdir -p "$out"
    export HOME=$TMPDIR
    ${rakudo}/bin/perl6 -I. ./bin/zef --/depends --/test-depends --/build-depends --install-to=$out install .
  '';

  postFixup =''
    wrapProgram $out/bin/zef \
      --prefix RAKUDOLIB : "inst#$out"
  '';

  meta = with stdenv.lib; {
    license     = licenses.artistic2;
    platforms   = platforms.unix;
  };
}
