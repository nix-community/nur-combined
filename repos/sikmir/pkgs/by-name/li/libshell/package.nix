{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  dash,
  ncurses,
  scdoc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libshell";
  version = "0.5.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "legionus";
    repo = "libshell";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Jl0JyC4StD0SBlDM2Ubjj42I7J55fIj15GMRhNxttwg=";
  };

  nativeBuildInputs = [ scdoc ];

  postPatch = ''
    substituteInPlace Makefile --replace-fail "/usr" ""
    substituteInPlace utils/Makefile --replace-fail "/usr" ""
    substituteInPlace utils/cgrep.in --replace-fail "/bin/ash" "${dash}/bin/dash"
    substituteInPlace shell-terminfo --replace-fail "tput" "${ncurses}/bin/tput"
    for f in shell-* ; do
      substituteInPlace $f --replace-warn "/bin/sh" "${bash}/bin/sh"
    done
  '';

  makeFlags = [ "DESTDIR=$(out)" ];

  doCheck = false;

  meta = {
    description = "A library of shell functions";
    homepage = "https://github.com/legionus/libshell";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
  };
})
