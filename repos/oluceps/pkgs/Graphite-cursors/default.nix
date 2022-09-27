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

  #  nativeBuildInputs = [ inkscape xcursorgen ];

  # buildPhase = ''
  #    patchShebangs .
  #    HOME=$TMP ./build.sh
  #  '';
  #
  installPhase = ''
    install -dm 755 $out/share/icons
    # cp -dr --no-preserve='ownership' dist{-dark{,-nord},-light{,-nord}} $out/share/icons/
    mv dist-dark $out/share/icons/Graphite-dark
    mv dist-light $out/share/icons/Graphite-light
    mv dist-dark-nord $out/share/icons/Graphite-dark-nord
    mv dist-light-nord $out/share/icons/Graphite-light-nord
  '';

  meta = with lib; {
    description = "Graphite cursor theme";
    homepage = "https://github.com/vinceliuice/Graphite-cursors";
    license = licenses.gpl3;
    platforms = platforms.all;
    #    maintainers = with maintainers; [ oluceps ];
  };
}
