{ stdenv, fetchFromGitHub, mbuild, enableShared ? true }:

stdenv.mkDerivation rec {
  name = "intelxed-${version}";
  version = "2018-10-19";
  src = fetchFromGitHub {
    owner = "intelxed";
    repo = "xed";
    rev = "7d62c8c49b7bb48de5512196610ad1689b3e5cee";
    sha256 = "0ppa7jqrj166m2n6p91x5qhi4bfkaq4zg47vx3nv2fvz5y77pm1w";
  };

  nativeBuildInputs = [ mbuild ];

  buildFlags = [
    "install"
    # "-v1"
  ]
    ++ stdenv.lib.optional stdenv.cc.isClang "--compiler=clang"
    ++ stdenv.lib.optional enableShared "--shared";

  installPhase = ''
    python ./mfile.py $buildFlags --prefix $out
  '';

  meta = with stdenv.lib; {
    description = "x86 encoder decoder";
    homepage = https://github.com/intelxed/xed;
    license = licenses.asl20;
  };
}
