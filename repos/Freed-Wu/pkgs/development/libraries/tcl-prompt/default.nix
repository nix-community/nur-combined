{ lib, fetchFromGitHub, tcl, tcllib, tclreadline }:

tcl.mkTclDerivation rec {
  name = "tcl-prompt";
  src = fetchFromGitHub {
    owner = "Freed-Wu";
    repo = name;
    rev = "597ae396c3cac9db7cd7d5e35a49436cc5942086";
    hash = "sha256-bL5vbVctYkcT5gPZ23hp7rjf2oMm3GjKjtSDGaNj7FA=";
  };

  buildInputs = [ tclreadline tcllib ];
  installPhase = ''
    install -d $out/lib
    cp -r modules $out/lib/tcl-prompt
  '';

  meta = with lib; {
    homepage = "https://github.com/Freed-Wu/tcl-prompt";
    description = "A powerlevel10k-like prompt for tcl";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
