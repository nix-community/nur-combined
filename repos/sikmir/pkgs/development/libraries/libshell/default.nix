{ stdenv
, bash
, dash
, help2man
, ncurses
, sources
, withDoc ? false
, scdoc
}:

stdenv.mkDerivation {
  pname = "libshell-unstable";
  version = stdenv.lib.substring 0 10 sources.libshell.date;

  src = sources.libshell;

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

  makeFlags = with stdenv.lib; [
    "DESTDIR=$(out)"
    (optional withDoc "SCDOC=${scdoc}/bin/scdoc")
    (optional (!withDoc) "SCDOC=")
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    inherit (sources.libshell) description homepage;
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
  };
}
