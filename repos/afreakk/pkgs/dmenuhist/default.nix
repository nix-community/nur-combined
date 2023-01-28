{ stdenv, ghc, fetchFromGitHub }:
stdenv.mkDerivation rec {
  name = "dmenuhistory";
  # version = "1.0.0";
  # src = ~/coding/dmenuhistory/dmenuhist.hs;
  version = "ad0e44a6b8662e481e8ded47dbffe73a552b3af7";
  src = fetchFromGitHub {
    rev = version;
    owner = "afreakk";
    repo = "dmenuhistory";
    sha256 = "sha256-0zH1kEL+aPcRoGc9YhI7+rw9Wv/Mk/4OyRC59+Ygm3k=";
  };
  buildInputs = [ ghc ];
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    ghc -O2 -tmpdir $TMPDIR -hidir $TMPDIR -odir $TMPDIR -o $out/bin/dmenuhist $src/dmenuhist.hs
  '';
}
