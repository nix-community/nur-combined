{
  lib,
  stdenv,
  fetchgit,
  ed,
  qbe,
  makeWrapper,
  buildPackages,
}:

stdenv.mkDerivation {
  pname = "scc";
  version = "0-unstable-2025-10-29";

  src = fetchgit {
    url = "git://git.simple-cc.org/scc";
    rev = "1ed0ff0000999561feee336c289252faf2502a7e";
    hash = "sha256-BVs+ypb6/aE2BsCsDMLZa2ppK6ypjLZQumUgzIehg/k=";
  };

  postPatch = ''
    substituteInPlace scripts/build/tool/gnu.mk \
      --replace-fail "TOOL_LDFLAGS" "#TOOL_LDFLAGS"
    substituteInPlace scripts/rules.mk \
      --replace-fail "PREFIX = /usr/local" "PREFIX = $out"
    substituteInPlace scripts/config \
      --replace-fail "PREFIX:=/usr/local" "PREFIX:=$out"
    substituteInPlace tests/Makefile \
      --replace-fail "libc/execute" "" \
      --replace-fail "cc/execute" "" \
      --replace-fail "make/execute" ""
  '';

  nativeBuildInputs = [
    ed
    qbe
    makeWrapper
  ];

  makeFlags = [
    "AR=${stdenv.cc.targetPrefix}ar"
    "AS=${stdenv.cc.targetPrefix}as"
    "CC=${stdenv.cc.targetPrefix}cc"
    "LD=${stdenv.cc.targetPrefix}ld"
    "RANLIB=${stdenv.cc.targetPrefix}ranlib"
    "HOSTCC=${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc"
  ];

  doCheck = true;
  checkTarget = "tests";

  postInstall = ''
    for i in $out/bin/*; do
      wrapProgram $i --prefix PATH : ${
        lib.makeBinPath [
          "$out"
          qbe
        ]
      }
    done
  '';

  meta = {
    description = "Simple c99 compiler";
    homepage = "https://www.simple-cc.org/";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
