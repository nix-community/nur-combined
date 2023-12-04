{ lib, fetchFromGitHub, tcl, tcllib, tclreadline, expect }:

tcl.mkTclDerivation rec {
  name = "tcl-prompt";
  src = fetchFromGitHub {
    owner = "Freed-Wu";
    repo = name;
    rev = "c48fed411601a2e6bdf3e7fabff9cb0c611689d4";
    hash = "sha256-oWGM/vrlOpPoCRT24DYPRFvF8Yf0uVgFgAwH942qGLQ=";
  };

  buildInputs = [ tclreadline tcllib expect ];
  installPhase = ''
    install -d $out/lib
    cp -r modules $out/lib/tcl-prompt
    cp -r bin $out
  '';

  meta = with lib; {
    homepage = "https://github.com/Freed-Wu/tcl-prompt";
    description = "Tcl plugin for powerlevel10k style prompt and WakaTime time tracking";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
