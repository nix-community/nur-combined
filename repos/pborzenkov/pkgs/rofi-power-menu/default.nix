{ lib, stdenv, fetchFromGitHub, rofi }:

stdenv.mkDerivation rec {
  pname = "rofi-power-menu";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "pborzenkov";
    repo = "rofi-power-menu";
    rev = "reboot-to-windows";
    sha256 = "sha256-tevpHHQ6QN9JawCh6o1E8LsddpQ3cvgBkW0nL+aw5/Q=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp rofi-power-menu $out/bin/rofi-power-menu
    cp dmenu-power-menu $out/bin/dmenu-power-menu
  '';

  meta = with lib; {
    description = "Shows a Power/Lock menu with Rofi";
    homepage = "https://github.com/jluttine/rofi-power-menu";
    maintainers = with maintainers; [ pborzenkov ];
    platforms = platforms.linux;
  };
}
