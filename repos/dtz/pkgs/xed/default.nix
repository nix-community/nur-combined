{ stdenv, fetchFromGitHub, mbuild, enableShared ? true }:

stdenv.mkDerivation rec {
  name = "intelxed-${version}";
  version = "2019-01-17";
  src = fetchFromGitHub {
    owner = "intelxed";
    repo = "xed";
    rev = "ca37abea8d32621edc031c631e5ca68dc398d4b6";
    sha256 = "1cg7jxsxqvri1h4ifj4pm8ib1sdaai30qgb3mbx9qpl1d7z41vgs";
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
