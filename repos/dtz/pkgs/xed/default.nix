{ stdenv, fetchFromGitHub, mbuild, enableShared ? true }:

stdenv.mkDerivation rec {
  name = "intelxed-${version}";
  version = "2018-09-14";
  src = fetchFromGitHub {
    owner = "intelxed";
    repo = "xed";
    rev = "fba18bc6347cca8c8a829e537bdb4eadb08033e0";
    sha256 = "1nzz8wa455ybq0fqdwigll4ih2z6zrg1j6qaxys76gf787k7ps8c";
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
