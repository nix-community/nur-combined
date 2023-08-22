{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, glew
, libtheora
, SDL2
}:

stdenv.mkDerivation rec {
  pname = "sonic-cd";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "Rubberduckycooly";
    repo = "Sonic-CD-11-Decompilation";
    rev = version;
    hash = "sha256-4RTUo5PESXcBFJk+Pu9XwfpUIkIkhyAhBg+yZ8y7Wk0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    glew
    libtheora
    SDL2
  ];

  makeFlags = [
    "prefix=${placeholder "out"}"
  ];

  postInstall = ''
    mkdir -p $out/share
    install -Dm00644 flatpak/com.sega.SonicCD.desktop $out/share/applications/com.sega.SonicCD.desktop
    install -Dm00644 flatpak/com.sega.SonicCD.svg $out/share/icons/hicolor/256x256/apps/com.sega.SonicCD.svg
    install -Dm00644 flatpak/com.sega.SonicCD.appdata.xml $out/share/appdata/com.sega.SonicCD.appdata.xml
  '';

  meta = with lib; {
    description = "A Full Decompilation of Sonic CD (2011) & Retro Engine (v3";
    homepage = "https://github.com/Rubberduckycooly/Sonic-CD-11-Decompilation";
    license = with licenses; [ unfree ];
    maintainers = with maintainers; [ federicoschonborn ];
  };
}
