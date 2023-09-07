{ lib, fetchFromGitHub, tcl, tcllib, tclreadline, expect }:

tcl.mkTclDerivation rec {
  name = "tcl-prompt";
  src = fetchFromGitHub {
    owner = "Freed-Wu";
    repo = name;
    rev = "b2d32ff6958377f8ab160c08ea1a5ebfbbee2b53";
    hash = "sha256-RR3BafvGpT8+5rnRKPxrMmn6vrpwWNQQAwFzemBWBTc=";
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
