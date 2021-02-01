{stdenv, ghc, fetchFromGitHub}:
stdenv.mkDerivation rec {
  name = "dmenuhistory";
  # version = "1.0.0";
  # src = ~/coding/dmenuhistory/dmenuhist.hs;
  version = "57c56ca9475cd05da8e1e48ec5b067981da15c62";
  src = fetchFromGitHub {
    rev = version;
    owner = "afreakk";
    repo = "dmenuhistory";
    sha256 = "087gdkgnvkgmsm27759jfvxhjjmrdpbwvqs5d6sh4jc4h1xwlmzj";
  };
  buildInputs = [ ghc ];
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    ghc -O2 -tmpdir $TMPDIR -hidir $TMPDIR -odir $TMPDIR -o $out/bin/dmenuhist $src/dmenuhist.hs
  '';
}
