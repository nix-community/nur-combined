{ stdenv, lib, fetchFromGitHub, makeWrapper, bash, coreutils, fzf, gawk, gnused }:

stdenv.mkDerivation rec {
  pname = "sway-launcher-desktop";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "Biont";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-T7mae100GTnc5mN3VnkNAQc3pIahombvRdP94CRXbEI=";
  };

  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm 0755 sway-launcher-desktop.sh $out/bin/sway-launcher-desktop
    wrapProgram $out/bin/sway-launcher-desktop --set PATH \
      "${lib.makeBinPath [ bash coreutils fzf gawk gnused ]}"
  '';

  meta = with lib; {
    description = "TUI Application launcher with Desktop Entry support";
    homepage = "https://github.com/Biont/sway-launcher-desktop";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ plabadens ];
  };
}
