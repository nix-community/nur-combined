{ lib, fetchFromGitHub, tcl, tcllib, tclreadline, expect }:

tcl.mkTclDerivation rec {
  name = "tcl-prompt";
  src = fetchFromGitHub {
    owner = "Freed-Wu";
    repo = name;
    rev = "bc29b670176c98a1d632cc520ded27eeb685cce4";
    hash = "sha256-HBAhirOM024tNSLRbB1eXswm3CVNsKyupislXoz9Wpk=";
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
