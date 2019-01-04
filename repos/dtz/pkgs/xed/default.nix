{ stdenv, fetchFromGitHub, mbuild, enableShared ? true }:

stdenv.mkDerivation rec {
  name = "intelxed-${version}";
  version = "2019-01-03";
  src = fetchFromGitHub {
    owner = "intelxed";
    repo = "xed";
    rev = "7ad6b5c15f19657d5749e8f0c26065ddd6db57b5";
    sha256 = "1v7bvw5wl11hkl84i1sr5zphnfy5d679jcj89in0rdvm4vy4wh3m";
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
