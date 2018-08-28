{ stdenv, fetchFromGitHub, mbuild, enableShared ? true }:

stdenv.mkDerivation rec {
  name = "intelxed-${version}";
  version = "2018-08-27";
  src = fetchFromGitHub {
    owner = "intelxed";
    repo = "xed";
    rev = "84ba6227c1a0fd0bd27474e53102252dd9747ba1";
    sha256 = "15syppkvsd3y1bz2f6j2qshj96ddjxcn83pfq6xnqiqa3a3x9wxp";
  };

  nativeBuildInputs = [ mbuild ];

  buildFlags = [
    "install"
    "-v1"
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
