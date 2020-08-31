{ fetchgit, fetchFromGitHub, stdenv
, bison, cmake, flex, gmp, libedit, makeWrapper, pkgconfig, readline
}:
let
  googletest = fetchgit {
    leaveDotGit = true;
    rev = "2fe3bd994b3189899d93f1d5a881e725e046fdc2"; # release-1.8.1
    sha256 = "16qsnf73yx4xcy6519cbwaq36pgzk0wsj77qjc88l0m0f31c8amw";
    url = "https://github.com/google/googletest.git/";
  };
  deps = "build/_deps";
  googletest-sourcedir = "googletest-src";
in
stdenv.mkDerivation rec {

  name = "opensmt2-${version}";
  version = "2.0.1";

  src = fetchgit {
    rev = "c857e2746ea20e901e201d9d909e2c119a63a625";
    sha256 = "0ccldiajqjgm8hh66w9vazrbimrpbisbna2vp041pi9iddfir0ms";
    url = "https://github.com/usi-verification-and-security/opensmt.git";
  };

  buildInputs = [  ];

  cmakeFlags = [
    # "-DCMAKE_BUILD_TYPE=Debug"
    "-DPRODUCE_PROOF=ON"
  ];

  nativeBuildInputs = [
    bison
    cmake
    flex
    gmp
    libedit
    makeWrapper
    pkgconfig
    readline
  ];

  meta = {
    description = "An SMT solver";
    homepage    = "verify.inf.usi.ch/opensmt";
    license     = stdenv.lib.licenses.mit;
    maintainers = [ stdenv.lib.maintainers.ptival ];
  };

  patches = [ ./no-git-clone.patch ];

  preConfigure = ''
    mkdir -p ${deps}
    (cd ${deps} && ln -s ${googletest} ${googletest-sourcedir})
  '';

}
