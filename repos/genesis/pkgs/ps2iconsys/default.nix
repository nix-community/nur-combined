{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  version = "unstable-2017-01-26";
  pname = "ps2iconsys";

  src = fetchFromGitHub {
    owner = "bignaux";
    #owner = "ticky";
    repo = "ps2iconsys";
    rev = "ec5cdc56d53bcfc7d79277f76c0ed2233da9ff9d";
    sha256 = "sha256-Se6gC3lPSoKOtDQomLrg/G9S2ICWxu/oDBMy/14lmHA=";
  };

  FILES = [ "iconsys_builder" "obj_to_ps2icon" "ps2icon_to_obj" ];

  installPhase = ''
    for bin in $FILES; do
      install -Dm755 $bin -t $out/bin
    done
  '';

  meta = with lib; {
    inherit (src.meta) homepage;
    description = "PlayStation 2 tools that allow the creation and manipulation of icons and ICON.SYS";
    platforms = platforms.linux;
    license = licenses.mit;
    maintainers = with maintainers; [ genesis ];
  };
}
