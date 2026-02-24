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
  version = "0-unstable-2026-02-20";

  src = fetchgit {
    url = "git://git.simple-cc.org/scc";
    rev = "05c02ab56769cd7ff85630d501627941d6abe84f";
    hash = "sha256-JW/aDsOF8AwosfCZ4E3pnEnsBM7exUl1lpVssLlKXl0=";
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

  doCheck = false;
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
