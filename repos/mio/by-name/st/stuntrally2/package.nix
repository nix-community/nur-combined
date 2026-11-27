{
  lib,
  fetchFromGitHub,
  stdenv,
  cmake,
  boost,
  ogre_13,
  mygui,
  ois,
  SDL2,
  libx11,
  libvorbis,
  pkg-config,
  makeWrapper,
  enet,
  libxcursor,
  bullet,
  openal,
  tinyxml,
  tinyxml-2,
  git,
  nix,
  python3,
  writeShellApplication,
}:

let
  stuntrally-ogre = ogre_13.overrideAttrs (oldAttrs: {
    version = "13.4.4";
    src = fetchFromGitHub {
      owner = "OGRECave";
      repo = "ogre";
      rev = "v13.4.4";
      hash = "sha256-P+4949VhFLyXu3rXghsJa4MqAtBHV8gsvveQnM3wOMY=";
    };
    cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
      "-DOGRE_NODELESS_POSITIONING=ON"
      "-DOGRE_RESOURCEMANAGER_STRICT=0"
    ];
  });

  stuntrally-mygui =
    (mygui.override {
      withOgre = true;
      ogre = stuntrally-ogre;
    }).overrideAttrs
      (oldAttrs: {
        version = "3.4.1";
        src = fetchFromGitHub {
          owner = "MyGUI";
          repo = "mygui";
          tag = "MyGUI3.4.1";
          hash = "sha256-5u9whibYKPj8tCuhdLOhL4nDisbFAB0NxxdjU/8izb8=";
        };
        patches = [ ];
        postPatch = ''
          substituteInPlace CMakeLists.txt \
            --replace-fail 'cmake_policy(SET CMP0048 OLD)' 'cmake_policy(SET CMP0048 NEW)'
          substituteInPlace CMake/Utils/MyGUIConfigTargets.cmake \
            --replace-fail 'FRAMEWORK TRUE' 'FRAMEWORK FALSE' \
            --replace-fail \
              'INSTALL_NAME_DIR "@executable_path/../Frameworks"' \
              'INSTALL_NAME_DIR "@executable_path/../lib"'
        '';
        cmakeFlags =
          builtins.filter (flag: !(lib.hasInfix "MYGUI_DONT_USE_OBSOLETE" flag)) (oldAttrs.cmakeFlags or [ ])
          ++ [
            (lib.cmakeBool "MYGUI_DONT_USE_OBSOLETE" false)
            (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
            (lib.cmakeFeature "CMAKE_CXX_STANDARD" "17")
            (lib.cmakeBool "CMAKE_CXX_STANDARD_REQUIRED" true)
          ];
        meta = (oldAttrs.meta or { }) // {
          badPlatforms = lib.subtractLists [ "aarch64-darwin" ] (oldAttrs.meta.badPlatforms or [ ]);
        };
      });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "stuntrally2";
  version = "2.7";

  src = fetchFromGitHub {
    owner = "stuntrally";
    repo = "stuntrally";
    tag = finalAttrs.version;
    hash = "sha256-0Eh9ilIHSh/Uz8TuPnXxLQfy7KF7qqNXUgBXQUCz9ys=";
  };

  tracks = fetchFromGitHub {
    owner = "stuntrally";
    repo = "tracks";
    tag = finalAttrs.version;
    hash = "sha256-fglm1FetFGHM/qGTtpxDb8+k2iAREn5DQR5GPujuLms=";
  };

  patches = [ ./stuntrally2-modern-dependencies.patch ];

  strictDeps = true;

  postPatch = ''
    substituteInPlace config/*-default.cfg \
      --replace-fail "screenshot_png = off" "screenshot_png = on"
    substituteInPlace source/*/BaseApp_Create.cpp \
      --replace-fail "Codec_FreeImage" "Codec_STBI"
    substituteInPlace source/editor/BaseApp_Create.cpp \
      --replace-fail \
        "string tex_name = imgSet->getIndexInfo(0,0).texture;" \
        "string tex_name(imgSet->getIndexInfo(0,0).texture);"
    substituteInPlace source/ogre/BaseApp_Create.cpp \
      --replace-fail \
        "std::string tex_name = imgSet->getIndexInfo(0,0).texture;" \
        "std::string tex_name(imgSet->getIndexInfo(0,0).texture);"
  '';

  preConfigure = ''
    rmdir data/tracks
    ln -s ${finalAttrs.tracks}/ data/tracks
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    boost
    stuntrally-ogre
    stuntrally-mygui
    ois
    SDL2
    libx11
    libvorbis
    enet
    libxcursor
    bullet
    openal
    tinyxml
    tinyxml-2
  ];

  cmakeFlags = [
    (lib.cmakeBool "SR_FORCE_SYSTEM_DEPENDENCIES" true)
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
    (lib.cmakeFeature "CMAKE_CXX_STANDARD" "17")
    (lib.cmakeBool "CMAKE_CXX_STANDARD_REQUIRED" true)
  ];

  postInstall = ''
    applications=$out/share/applications
    icons=$out/share/icons/hicolor/512x512/apps

    mv "$applications/stuntrally.desktop" "$applications/stuntrally2.desktop"
    substituteInPlace "$applications/stuntrally2.desktop" \
      --replace-fail "Name=Stunt Rally" "Name=Stunt Rally 2" \
      --replace-fail "Icon=stuntrally" "Icon=stuntrally2"
    mv "$icons/stuntrally.png" "$icons/stuntrally2.png"

    mv "$applications/sr-editor.desktop" "$applications/sr-editor2.desktop"
    substituteInPlace "$applications/sr-editor2.desktop" \
      --replace-fail "Name=Stunt Rally Track Editor" "Name=Stunt Rally 2 Track Editor" \
      --replace-fail "Icon=sr-editor" "Icon=sr-editor2"
    mv "$icons/sr-editor.png" "$icons/sr-editor2.png"

    ${lib.optionalString stdenv.hostPlatform.isLinux ''
      for binary in StuntRally SR-Editor SR-Translator
      do
        wrapProgram $out/bin/$binary \
          --set SDL_VIDEODRIVER x11
      done
    ''}
  '';

  passthru = {
    inherit (finalAttrs) tracks;
    mygui = stuntrally-mygui;
    ogre = stuntrally-ogre;

    updateScript = writeShellApplication {
      name = "update-stuntrally2";
      runtimeInputs = [
        git
        nix
        python3
      ];
      text = ''
        exec python3 ${./update.py} "$@"
      '';
    };
  };

  meta = {
    description = "Stunt Rally 2 game with Track Editor, based on VDrift and OGRE";
    homepage = "https://cryham.org/stuntrally/";
    mainProgram = "StuntRally";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
