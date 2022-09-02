{ lib
, stdenv
, fetchFromGitHub
, bash
, dash
, help2man
, ncurses
, withDoc ? false
, scdoc
}:

stdenv.mkDerivation rec {
  pname = "libshell";
  version = "0.4.9";

  src = fetchFromGitHub {
    owner = "legionus";
    repo = "libshell";
    rev = "v${version}";
    hash = "sha256-BkKBmKzmL3O+BQi4VZm3agRLpQ8nIZ2ZhQBL40oeCy4=";
  };

  nativeBuildInputs = [ help2man ];

  postPatch = ''
    substituteInPlace Makefile --replace "/usr" ""
    substituteInPlace utils/Makefile --replace "/usr" ""
    substituteInPlace utils/cgrep.in --replace "/bin/ash" "${dash}/bin/dash"
    substituteInPlace shell-terminfo --replace "tput" "${ncurses}/bin/tput"
    for f in shell-* ; do
      substituteInPlace $f --replace "/bin/sh" "${bash}/bin/sh"
    done
  '';

  makeFlags = with lib; [
    "DESTDIR=$(out)"
    (optional withDoc "SCDOC=${scdoc}/bin/scdoc")
    (optional (!withDoc) "SCDOC=")
  ];

  doCheck = false;

  meta = with lib; {
    description = "A library of shell functions";
    inherit (src.meta) homepage;
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
  };
}
