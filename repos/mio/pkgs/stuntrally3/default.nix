{
  lib,
  fetchFromGitHub,
  stdenv,
  cmake,
  boost,
  ogre-next_3,
  mygui,
  ois,
  SDL2,
  libX11,
  libvorbis,
  pkg-config,
  makeWrapper,
  enet,
  libXcursor,
  bullet,
  openal,
  tinyxml,
  tinyxml-2,
}:

let
  stuntrally_ogre = ogre-next_3.overrideAttrs (old: {
    cmakeFlags = old.cmakeFlags ++ [
      "-DOGRE_NODELESS_POSITIONING=ON"
      "-DOGRE_RESOURCEMANAGER_STRICT=0"
    ];
  });
  stuntrally_mygui = (
    mygui.override {
      withOgre = true;
      ogre = stuntrally_ogre;
    }
  );
in

stdenv.mkDerivation rec {
  pname = "stuntrally";
  version = "3.3";

  src = fetchFromGitHub {
    owner = "stuntrally";
    repo = "stuntrally3";
    rev = version;
    hash = "sha256-BJMMsJ/ONZTpvXetaaHlgm6rih9oZmtJNBXv0IM855Y=";
  };
  tracks = fetchFromGitHub {
    owner = "stuntrally";
    repo = "tracks3";
    rev = version;
    hash = "sha256-nvIN5hIfTfnuJdlLNlmpmYo3WQhUxYWz14OFra/55w4=";
  };

  #postPatch = ''
  #  substituteInPlace config/*-default.cfg \
  #    --replace "screenshot_png = off" "screenshot_png = on"
  #  substituteInPlace source/*/BaseApp_Create.cpp \
  #    --replace "Codec_FreeImage" "Codec_STBI"
  #'';

  preConfigure = ''
    ln -s ${tracks}/ data/tracks
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];
  buildInputs = [
    boost
    stuntrally_ogre
    stuntrally_mygui
    ois
    SDL2
    libX11
    libvorbis
    enet
    libXcursor
    bullet
    openal
    tinyxml
    tinyxml-2
  ];

  meta = with lib; {
    description = "Stunt Rally game with Track Editor, based on VDrift and OGRE";
    homepage = "http://stuntrally.tuxfamily.org/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ pSub ];
    platforms = platforms.linux;
  };
}
