{
  lib,
  stdenv,
  fetchgit,
  ed,
  qbe,
  makeWrapper,
}:

stdenv.mkDerivation {
  pname = "scc";
  version = "0-unstable-2025-10-17";

  src = fetchgit {
    url = "git://git.simple-cc.org/scc";
    rev = "e19109cd35b8d64480c74389b8faaedf5af9b0ed";
    hash = "sha256-YTHPCslPoI70z92JuPzGRQQyk0GVixPAvqPbAaiJNb4=";
  };

  postPatch = ''
    substituteInPlace scripts/build/tool/gnu.mk \
      --replace-fail "TOOL_LDFLAGS" "#TOOL_LDFLAGS"
    substituteInPlace scripts/rules.mk \
      --replace-fail "PREFIX = /usr/local" "PREFIX = $out"
    substituteInPlace scripts/config \
      --replace-fail "PREFIX:=/usr/local" "PREFIX:=$out"
  '';

  nativeBuildInputs = [
    ed
    qbe
    makeWrapper
  ];

  buildFlags = [
    "AR:=$(AR)"
    "AS:=$(AS)"
    "CC:=$(CC)"
    "RANLIB:=$(RANLIB)"
    "HOSTCC=${stdenv.cc.targetPrefix}cc"
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
