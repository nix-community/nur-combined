{ lib
, stdenv
, fetchFromGitHub
, inkscape
, xcursorgen
}:

stdenv.mkDerivation rec {
  pname = "Graphite-cursors";
  version = "2021-11-26";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256-Kopl2NweYrq9rhw+0EUMhY/pfGo4g387927TZAhI5/A=";
  };

  installPhase = ''
    install -dm 755 $out/share/icons
    mv dist-dark $out/share/icons/Graphite-dark
    mv dist-light $out/share/icons/Graphite-light
    mv dist-dark-nord $out/share/icons/Graphite-dark-nord
    mv dist-light-nord $out/share/icons/Graphite-light-nord
  '';

  # to use:
  #
  # home.pointerCursor = {
  #   package = pkgs.nur.oluceps.Graphite-cursors;
  #   name = "Graphite-light-nord";
  #   size = 22;
  # };


  meta = with lib; {
    description = "Graphite cursor theme";
    homepage = "https://github.com/vinceliuice/Graphite-cursors";
    license = licenses.gpl3;
    platforms = platforms.all;
    #    maintainers = with maintainers; [ oluceps ];
  };
}
