{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  dash,
  help2man,
  ncurses,
  withDoc ? false,
  scdoc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libshell";
  version = "0.4.13";

  src = fetchFromGitHub {
    owner = "legionus";
    repo = "libshell";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jolr55qNG3224IWRE9PueeRbO5RIhFmFiPe0g0wO9c4=";
  };

  nativeBuildInputs = [ help2man ];

  postPatch = ''
    substituteInPlace Makefile --replace-fail "/usr" ""
    substituteInPlace utils/Makefile --replace-fail "/usr" ""
    substituteInPlace utils/cgrep.in --replace-fail "/bin/ash" "${dash}/bin/dash"
    substituteInPlace shell-terminfo --replace-fail "tput" "${ncurses}/bin/tput"
    for f in shell-* ; do
      substituteInPlace $f --replace-warn "/bin/sh" "${bash}/bin/sh"
    done
  '';

  makeFlags = with lib; [
    "DESTDIR=$(out)"
    (optional withDoc "SCDOC=${scdoc}/bin/scdoc")
    (optional (!withDoc) "SCDOC=")
  ];

  doCheck = false;

  meta = {
    description = "A library of shell functions";
    homepage = "https://github.com/legionus/libshell";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
  };
})
