{ lib, fetchFromGitHub, tcl, tcllib, tclreadline, expect }:

tcl.mkTclDerivation rec {
  name = "tcl-prompt";
  src = fetchFromGitHub {
    owner = "Freed-Wu";
    repo = name;
    rev = "63166f2c3c181205292435bb439c52cc1fa84776";
    hash = "sha256-Z5l7RsgYh3maGgfKLEIhsel5g5KDa/TjmaORLXn8jUc=";
  };

  buildInputs = [ tclreadline tcllib expect ];
  installPhase = ''
    install -d $out/lib
    cp -r modules $out/lib/tcl-prompt
    cp -r bin $out
  '';

  meta = with lib; {
    homepage = "https://github.com/Freed-Wu/tcl-prompt";
    description = "A powerlevel10k-like prompt for tcl";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
