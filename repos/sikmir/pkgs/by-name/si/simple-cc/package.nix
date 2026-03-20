{
  lib,
  stdenv,
  fetchurl,
  ed,
  qbe,
  makeWrapper,
  buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "simple-cc";
  version = "0.1";

  src = fetchurl {
    url = "https://www.simple-cc.org/releases/scc-${finalAttrs.version}.tar.gz";
    hash = "sha256-0oZUxtl1GxUMmeXLHhSn2SVQdOyaWzPn7IP4jnlcaS8=";
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
})
