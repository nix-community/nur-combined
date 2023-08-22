{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, glew
, libtheora
, SDL2
}:

stdenv.mkDerivation rec {
  pname = "sonic-2013";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "Rubberduckycooly";
    repo = "Sonic-1-2-2013-Decompilation";
    rev = version;
    hash = "sha256-bryiJD6e7g3dzo9FVukm/5gP+gChQ7/ilU5N/PuSF6Q=";
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
    for version in 1 2; do
      install -Dm00644 flatpak/com.sega.Sonic$version.desktop $out/share/applications/com.sega.Sonic$version.desktop
      install -Dm00644 flatpak/com.sega.Sonic$version.svg $out/share/icons/hicolor/256x256/apps/com.sega.Sonic$version.svg
      install -Dm00644 flatpak/com.sega.Sonic$version.appdata.xml $out/share/appdata/com.sega.Sonic$version.appdata.xml
    done
  '';

  meta = with lib; {
    description = "A complete decompilation of Sonic 1 & Sonic 2 (2013) & Retro Engine (v4)";
    homepage = "https://github.com/Rubberduckycooly/Sonic-1-2-2013-Decompilation";
    license = with licenses; [ unfree ];
    maintainers = with maintainers; [ federicoschonborn ];
    # TODO: Missing X libraries.
    broken = true;
  };
}
