{ stdenv, fetchFromGitHub, mbuild, enableShared ? true }:

stdenv.mkDerivation rec {
  name = "intelxed-${version}";
  version = "2019-02-11";
  src = fetchFromGitHub {
    owner = "intelxed";
    repo = "xed";
    rev = "642093d6b32bc194cd0e7620eee39fbadb696b41";
    sha256 = "1dn2gr0l055jwvzdpqlh0wyvy3hamc4vhm7c0yb6zvd0p50fzzl7";
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
