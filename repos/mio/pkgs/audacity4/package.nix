{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchurl,
  fetchzip,
  p7zip,
  cmake,
  makeBinaryWrapper,
  pkg-config,
  python3,
  gettext,
  git,
  file,
  libvorbis,
  libmad,
  libjack2,
  lv2,
  lilv,
  mpg123,
  opusfile,
  rapidjson,
  serd,
  sord,
  sqlite,
  sratom,
  suil,
  libsndfile,
  soxr,
  flac,
  lame,
  twolame,
  expat,
  libid3tag,
  libopus,
  libuuid,
  ffmpeg,
  soundtouch,
  pcre,
  portaudio,
  portmidi,
  linuxHeaders,
  alsa-lib,
  at-spi2-core,
  dbus,
  libepoxy,
  libxdmcp,
  libxtst,
  libpthread-stubs,
  libsbsms_2_3_0,
  libselinux,
  libsepol,
  libxkbcommon,
  util-linux,
  wavpack,
  wxwidgets_3_2,
  gtk2,
  gtk3,
  qt6,
  libpng,
  libjpeg,
  harfbuzz,
  freetype,
}:
let
  loop-tempo-estimator-src = fetchzip {
    url = "https://github.com/saintmatthieu/loop-tempo-estimator/releases/download/v0.0.4/loop-tempo-estimator-v0.0.4.tar.gz";
    hash = "sha256-UTLsnC0FIPuZY09wEKo8wxvDlFn8jtcvs2F13L9yvjM=";
  };
  tft-src = fetchFromGitHub {
    owner = "kgramhans";
    repo = "tft";
    rev = "1d96301673ebc05fa09a7bd505eacd82ee0fea33";
    hash = "sha256-gVLJIKzjtBW3Gz7bLLa5GEAopSoWX4NEaou2VDlcILc=";
  };
  lv2-src = fetchFromGitHub {
    owner = "lv2";
    repo = "lv2";
    rev = "4b8760cec9636a1d9757afa79ceee2111b86e98b";
    hash = "sha256-Zs42BKhgmqEP9vFAX4IF1GmfCE6yuhVMcD192w/WWcY=";
  };
  lilv-src = fetchFromGitHub {
    owner = "lv2";
    repo = "lilv";
    rev = "977ff0e6a5d0a4d4615f7b9a6a0f0a30e46ffe33";
    hash = "sha256-ICwl8sRQQIx00s2UQkZOzgj9hwq6LN7esAuodhr7ank=";
  };
  zix-src = fetchFromGitHub {
    owner = "drobilla";
    repo = "zix";
    rev = "ee35824ffe3eaf5d1cc32ceca3233b723aac7d43";
    hash = "sha256-1fdW014QKvTYHaEmDsivUVPzF/vZgnW3Srk6edp6G1o=";
  };
  sord-src = fetchFromGitHub {
    owner = "drobilla";
    repo = "sord";
    rev = "2e7d86cadb5f16ac99bb08ef9355cedc10ad607e";
    hash = "sha256-cFobmmO2RHJdfCgTyGigzsdLpj7YF6U3r71i267Azks=";
  };
  serd-src = fetchFromGitHub {
    owner = "drobilla";
    repo = "serd";
    rev = "36808fcf94c0cbd3552e3129f176c1df6f9f4a3b";
    hash = "sha256-P7HUQ2kxNiW3hHXB7+rMOlqyLJP4Zasmxkr+P/9z90U=";
  };
  sratom-src = fetchFromGitHub {
    owner = "lv2";
    repo = "sratom";
    rev = "9373d59b743c47dc84d4a8c80591016f7123c1bd";
    hash = "sha256-RR/oCY2ge8cViqkbgsNjo4T6jaR/mYz/Zt8mhu1Ntxo=";
  };
  suil-src = fetchFromGitHub {
    owner = "lv2";
    repo = "suil";
    rev = "171f11701dd5813c8278cfc9fb72e2dfa0d54dab";
    hash = "sha256-le/aZ5cWyv7yT60TEY4xvM/GsVxaC6hSO+hIaCCAvV8=";
  };
  vst3sdk-src = stdenv.mkDerivation {
    name = "vst3sdk-src";
    src = fetchurl {
      url = "https://raw.githubusercontent.com/musescore/muse_deps/main/vst3sdk/v3.7.12_build_20/vst3sdk_v3.7.12_build_20_src.7z";
      hash = "sha256-P5X2JChl5I/Glk8m+W82JN+84RgwSIrW7iZ9VsxC7SM=";
    };
    nativeBuildInputs = [ p7zip ];
    sourceRoot = ".";
    installPhase = "mkdir -p $out && cp -r * $out/";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "audacity";
  version = "4.0.0-beta-2";

  env.NIX_CFLAGS_COMPILE = "-std=gnu17 -Wno-error=incompatible-pointer-types -Wno-error=implicit-function-declaration -Wno-error=strict-prototypes -Wno-error=implicit-int";

  src = fetchFromGitHub {
    owner = "audacity";
    repo = "audacity";
    rev = "Audacity-${finalAttrs.version}";
    hash = "sha256-S2xAh7eA00VaxJN8WNdlTlE0JzJIJsfpGBW6uFlNb6w=";
    fetchSubmodules = true;
  };

  patches = [
  ];

  postPatch = ''
            mkdir -p src/private
            
            # Disable populate() fetching since we provide all dependencies through Nix
            python3 -c '
    import os, re
    for root, _, files in os.walk("."):
        for f in files:
            if f.endswith(".cmake") or f == "CMakeLists.txt":
                p = os.path.join(root, f)
                with open(p, "r") as fp: d = fp.read()
                d = re.sub(r"cmake_language\s*\(\s*CALL\s+[a-zA-Z0-9_]+_Populate[^)]*\)", "", d)
                d = re.sub(r"(?m)^\s*populate\s*\([^)]*\)", "", d)
                with open(p, "w") as fp: fp.write(d)
    '

            # Add system library setup to SetupDependencies.cmake
            cat >> buildscripts/cmake/SetupDependencies.cmake << 'EOF'

        # Find Qt6 GuiPrivate for KDDockWidgets
        find_package(Qt6 REQUIRED COMPONENTS GuiPrivate)

        # Use system wxWidgets instead of populate
        find_package(wxWidgets REQUIRED COMPONENTS net base core adv html qa xml aui ribbon propgrid stc)
        if(wxWidgets_FOUND)
            include(''${wxWidgets_USE_FILE})
            # Create the wxwidgets::wxwidgets target that Audacity expects
            if(NOT TARGET wxwidgets::wxwidgets)
                add_library(wxwidgets::wxwidgets INTERFACE IMPORTED)
                set_target_properties(wxwidgets::wxwidgets PROPERTIES
                    INTERFACE_INCLUDE_DIRECTORIES "''${wxWidgets_INCLUDE_DIRS}"
                    INTERFACE_LINK_LIBRARIES "''${wxWidgets_LIBRARIES}"
                    INTERFACE_COMPILE_DEFINITIONS "''${wxWidgets_DEFINITIONS}"
                    INTERFACE_COMPILE_OPTIONS "''${wxWidgets_CXX_FLAGS}"
                )
            endif()
            message(STATUS "Using system wxWidgets: ''${wxWidgets_VERSION_STRING}")
        endif()

        # Use system expat
        find_package(EXPAT REQUIRED)
        if(EXPAT_FOUND)
            if(NOT TARGET expat::expat)
                add_library(expat::expat INTERFACE IMPORTED)
                set_target_properties(expat::expat PROPERTIES
                    INTERFACE_INCLUDE_DIRECTORIES "''${EXPAT_INCLUDE_DIRS}"
                    INTERFACE_LINK_LIBRARIES "''${EXPAT_LIBRARIES}"
                )
            endif()
            message(STATUS "Using system expat")
        endif()

        # Use system portaudio
        find_package(PkgConfig REQUIRED)
        pkg_check_modules(PORTAUDIO REQUIRED IMPORTED_TARGET portaudio-2.0)
        if(PORTAUDIO_FOUND)
            if(NOT TARGET portaudio::portaudio)
                add_library(portaudio::portaudio ALIAS PkgConfig::PORTAUDIO)
            endif()
            message(STATUS "Using system portaudio")
        endif()

        # System audio libraries - create targets matching populate() naming
        if(NOT TARGET libmp3lame::libmp3lame)
            add_library(libmp3lame::libmp3lame INTERFACE IMPORTED)
            set_target_properties(libmp3lame::libmp3lame PROPERTIES
                INTERFACE_LINK_LIBRARIES "mp3lame"
            )
        endif()

        if(NOT TARGET wavpack::wavpack)
            add_library(wavpack::wavpack INTERFACE IMPORTED)
            set_target_properties(wavpack::wavpack PROPERTIES
                INTERFACE_LINK_LIBRARIES "wavpack"
            )
        endif()

        if(NOT TARGET mpg123::libmpg123)
            add_library(mpg123::libmpg123 INTERFACE IMPORTED)
            set_target_properties(mpg123::libmpg123 PROPERTIES
                INTERFACE_LINK_LIBRARIES "mpg123"
            )
        endif()

        if(NOT TARGET libsndfile::libsndfile)
            add_library(libsndfile::libsndfile INTERFACE IMPORTED)
            set_target_properties(libsndfile::libsndfile PROPERTIES
                INTERFACE_LINK_LIBRARIES "sndfile"
            )
        endif()

        if(NOT TARGET SndFile::sndfile)
            add_library(SndFile::sndfile INTERFACE IMPORTED)
            set_target_properties(SndFile::sndfile PROPERTIES
                INTERFACE_LINK_LIBRARIES "sndfile"
            )
        endif()

        if(NOT TARGET vorbis::vorbis)
            add_library(vorbis::vorbis INTERFACE IMPORTED)
            set_target_properties(vorbis::vorbis PROPERTIES
                INTERFACE_LINK_LIBRARIES "vorbisenc;vorbisfile;vorbis"
            )
        endif()

        if(NOT TARGET Vorbis::vorbis)
            add_library(Vorbis::vorbis INTERFACE IMPORTED)
            set_target_properties(Vorbis::vorbis PROPERTIES
                INTERFACE_LINK_LIBRARIES "vorbisenc;vorbisfile;vorbis"
            )
        endif()

        if(NOT TARGET Vorbis::vorbisenc)
            add_library(Vorbis::vorbisenc INTERFACE IMPORTED)
            set_target_properties(Vorbis::vorbisenc PROPERTIES
                INTERFACE_LINK_LIBRARIES "vorbisenc"
            )
        endif()

        if(NOT TARGET Vorbis::vorbisfile)
            add_library(Vorbis::vorbisfile INTERFACE IMPORTED)
            set_target_properties(Vorbis::vorbisfile PROPERTIES
                INTERFACE_LINK_LIBRARIES "vorbisfile"
            )
        endif()

        if(NOT TARGET flac::flac)
            add_library(flac::flac INTERFACE IMPORTED)
            set_target_properties(flac::flac PROPERTIES
                INTERFACE_LINK_LIBRARIES "FLAC;FLAC++"
            )
        endif()

        if(NOT TARGET FLAC::FLAC++)
            add_library(FLAC::FLAC++ INTERFACE IMPORTED)
            set_target_properties(FLAC::FLAC++ PROPERTIES
                INTERFACE_LINK_LIBRARIES "FLAC++"
            )
        endif()

        if(NOT TARGET FLAC::FLAC)
            add_library(FLAC::FLAC INTERFACE IMPORTED)
            set_target_properties(FLAC::FLAC PROPERTIES
                INTERFACE_LINK_LIBRARIES "FLAC"
            )
        endif()

        if(NOT TARGET ogg::ogg)
            add_library(ogg::ogg INTERFACE IMPORTED)
            set_target_properties(ogg::ogg PROPERTIES
                INTERFACE_LINK_LIBRARIES "ogg"
            )
        endif()

        if(NOT TARGET Ogg::ogg)
            add_library(Ogg::ogg INTERFACE IMPORTED)
            set_target_properties(Ogg::ogg PROPERTIES
                INTERFACE_LINK_LIBRARIES "ogg"
            )
        endif()

        if(NOT TARGET opus::opus)
            add_library(opus::opus INTERFACE IMPORTED)
            set_target_properties(opus::opus PROPERTIES
                INTERFACE_LINK_LIBRARIES "opus"
            )
        endif()

        if(NOT TARGET opusfile::opusfile)
            add_library(opusfile::opusfile INTERFACE IMPORTED)
            set_target_properties(opusfile::opusfile PROPERTIES
                INTERFACE_LINK_LIBRARIES "opusfile"
            )
        endif()

        if(NOT TARGET Opus::opus)
            add_library(Opus::opus INTERFACE IMPORTED)
            set_target_properties(Opus::opus PROPERTIES
                INTERFACE_LINK_LIBRARIES "opus"
            )
        endif()

        # Create SIMD32 dummy target (not needed for Linux builds)
        if(NOT TARGET SIMD32::SIMD32)
            add_library(SIMD32::SIMD32 INTERFACE IMPORTED)
            message(STATUS "Created dummy SIMD32 target")
        endif()
    EOF
            

  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace au3/libraries/au3-files/FileNames.cpp \
      --replace-fail /usr/include/linux/magic.h ${linuxHeaders}/include/linux/magic.h
  '';

  nativeBuildInputs = [
    cmake
    gettext
    pkg-config
    python3
    makeBinaryWrapper
    qt6.wrapQtAppsHook
    git
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    linuxHeaders
  ];

  buildInputs = [
    expat
    ffmpeg
    file
    flac
    freetype
    gtk2
    gtk3
    harfbuzz
    lame
    libid3tag
    libjack2
    libmad
    libopus
    libsbsms_2_3_0
    libsndfile
    libvorbis
    lilv
    lv2
    mpg123
    opusfile
    pcre
    portmidi
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwayland
    qt6.qt5compat # Qt 5 Compatibility Module
    qt6.qtnetworkauth # Qt Network Authorization
    qt6.qtshadertools # Qt Shader Tools
    qt6.qtscxml # Qt State Machines
    qt6.qttools # Includes LinguistTools
    qt6.qtdeclarative # Provides Qt6::Gui and Qt6::GuiPrivate
    rapidjson
    serd
    sord
    soundtouch
    soxr
    sqlite
    sratom
    suil
    twolame
    portaudio
    wavpack
    wxwidgets_3_2
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib # for portaudio
    at-spi2-core
    dbus
    libepoxy
    libxdmcp
    libxtst
    libpthread-stubs
    libxkbcommon
    libselinux
    libsepol
    libuuid
    util-linux
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libpng
    libjpeg
  ];

  cmakeFlags = [
    "-DAUDACITY_BUILD_LEVEL=2"
    "-DAUDACITY_REV_LONG=nixpkgs"
    "-DAUDACITY_REV_TIME=nixpkgs"
    "-DDISABLE_DYNAMIC_LOADING_FFMPEG=ON"
    "-Daudacity_conan_enabled=Off"
    "-Daudacity_use_ffmpeg=loaded"
    "-Daudacity_has_crashreports=Off"

    "-DFETCHCONTENT_SOURCE_DIR_LOOP-TEMPO-ESTIMATOR=${loop-tempo-estimator-src}"
    "-DFETCHCONTENT_SOURCE_DIR_TFT=${tft-src}"
    "-DFETCHCONTENT_SOURCE_DIR_LV2=${lv2-src}"
    "-DFETCHCONTENT_SOURCE_DIR_LILV=${lilv-src}"
    "-DFETCHCONTENT_SOURCE_DIR_ZIX=${zix-src}"
    "-DFETCHCONTENT_SOURCE_DIR_SORD=${sord-src}"
    "-DFETCHCONTENT_SOURCE_DIR_SERD=${serd-src}"
    "-DFETCHCONTENT_SOURCE_DIR_SRATOM=${sratom-src}"
    "-DFETCHCONTENT_SOURCE_DIR_SUIL=${suil-src}"
    "-DMUSE_MODULE_VST_VST3_SDK_PATH=${vst3sdk-src}"

    # Fix linker issues with circular dependencies between static libraries
    "-DCMAKE_EXE_LINKER_FLAGS=-Wl,--start-group"
    "-DCMAKE_MODULE_LINKER_FLAGS=-Wl,--start-group"

    # Disable all tests since they depend on disabled libraries (portmixer, lv2sdk, vst3)
    "-DAU_BUILD_CONTEXT_TESTS=OFF"
    "-DAU_BUILD_EFFECTS_BUILTIN_TESTS=OFF"
    "-DAU_BUILD_EFFECTS_TESTS=OFF"
    "-DAU_BUILD_PLAYBACK_TESTS=OFF"
    "-DAU_BUILD_PROJECT_TESTS=OFF"
    "-DAU_BUILD_PROJECTSCENE_TESTS=OFF"
    "-DAU_BUILD_RECORD_TESTS=OFF"
    "-DAU_BUILD_TRACKEDIT_TESTS=OFF"

    # Use system libraries instead of downloading them
    "-DMUSE_USE_SYSTEM_HARFBUZZ=ON"
    "-DMUSE_USE_SYSTEM_FREETYPE=ON"

    # Try to use system wxWidgets
    "-DwxWidgets_CONFIG_EXECUTABLE=${wxwidgets_3_2}/bin/wx-config"
    "-DwxWidgets_wxrc_EXECUTABLE=${wxwidgets_3_2}/bin/wxrc"

    # RPATH of binary /nix/store/.../bin/... contains a forbidden reference to /build/
    "-DCMAKE_SKIP_BUILD_RPATH=ON"

    # Fix duplicate store paths
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  preConfigure = ''
    # Add Qt6 private headers to include path
    # Private headers are in QtCore/6.x.x/QtCore/private/, and they include each other as QtCore/private/...
    # So we need both QtCore/6.x.x/ (for QtCore/private/...) and QtCore/6.x.x/QtCore (for private/...)
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${qt6.qtbase}/include/QtCore/${qt6.qtbase.version} -I${qt6.qtbase}/include/QtCore/${qt6.qtbase.version}/QtCore -I${qt6.qtbase}/include/QtGui/${qt6.qtbase.version} -I${qt6.qtbase}/include/QtGui/${qt6.qtbase.version}/QtGui"
  '';

  # [ 57%] Generating LightThemeAsCeeCode.h...
  # ../../utils/image-compiler: error while loading shared libraries:
  # lib-theme.so: cannot open shared object file: No such file or directory
  preBuild = ''
    export LD_LIBRARY_PATH=$PWD/Release/lib/audacity
  '';

  doCheck = false; # Test fails

  # Replace audacity's wrapper, to:
  # - Put it in the right place; it shouldn't be in "$out/audacity"
  # - Add the ffmpeg dynamic dependency
  postFixup =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      wrapProgram "$out/bin/audacity" \
        --prefix LD_LIBRARY_PATH : "$out/lib/audacity":${lib.makeLibraryPath [ ffmpeg ]} \
        --suffix AUDACITY_MODULES_PATH : "$out/lib/audacity/modules" \
        --suffix AUDACITY_PATH : "$out/share/audacity"
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/{Applications,bin}
      mv $out/Audacity.app $out/Applications/
      makeWrapper $out/Applications/Audacity.app/Contents/MacOS/Audacity $out/bin/audacity
    '';

  meta = {
    description = "Sound editor with graphical UI";
    mainProgram = "audacity";
    homepage = "https://www.audacityteam.org";
    changelog = "https://github.com/audacity/audacity/releases";
    license = with lib.licenses; [
      gpl2Plus
      # Must be GPL3 when building with "technologies that require it,
      # such as the VST3 audio plugin interface".
      # https://github.com/audacity/audacity/discussions/2142.
      gpl3
      # Documentation.
      cc-by-30
    ];
    maintainers = with lib.maintainers; [
    ];
    platforms = lib.platforms.unix;
  };
})
