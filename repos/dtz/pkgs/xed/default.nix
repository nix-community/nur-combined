{ stdenv, fetchFromGitHub, mbuild, enableShared ? true }:

stdenv.mkDerivation rec {
  name = "intelxed-${version}";
  version = "2018-11-01";
  src = fetchFromGitHub {
    owner = "intelxed";
    repo = "xed";
    rev = "377d7dbbf8aaa198a46e4e3886a31f3e10de45ac";
    sha256 = "0ababm1s76394raabsjn7yrfz5l4rg5dlkililzrcdwl1j86y651";
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
