{ stdenv, fetchFromGitHub, mbuild, enableShared ? true }:

stdenv.mkDerivation rec {
  name = "intelxed-${version}";
  version = "2018-08-14";
  src = fetchFromGitHub {
    owner = "intelxed";
    repo = "xed";
    rev = "a6bb1116cf8a6ae35b5dd7e2cf7dd9127e21d952";
    sha256 = "067cpyh5rcgk7jnvmkz6230apmba9243nh5gy0pwpd15dzfmckjv";
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
