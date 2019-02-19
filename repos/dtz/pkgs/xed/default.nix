{ stdenv, fetchFromGitHub, mbuild, enableShared ? true }:

stdenv.mkDerivation rec {
  name = "intelxed-${version}";
  version = "2019-02-14";
  src = fetchFromGitHub {
    owner = "intelxed";
    repo = "xed";
    rev = "63532eed6bd5f5ac5115385c1debb7bd5ff57acb";
    sha256 = "1blvdvamyqs0i1df16ks3ji71rbk28by5bqj3jcgvkslq1xz4yq0";
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
