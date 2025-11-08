{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  makeWrapper,
  wrapQtAppsHook,
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
  libXdmcp,
  libXtst,
  libpthreadstubs,
  libsbsms_2_3_0,
  libselinux,
  libsepol,
  libxkbcommon,
  util-linux,
  wavpack,
  wxGTK32,
  gtk2,
  gtk3,
  qt6,
  libpng,
  libjpeg,
  harfbuzz,
  freetype,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "audacity";
  version = "4-unstable-20251028";

  src = fetchFromGitHub {
    owner = "audacity";
    repo = "audacity";
    # https://github.com/audacity/audacity/commits/master/
    rev = "2e0abc1670d5528df58fff5a4affd0ccd51a3500";
    hash = "sha256-QxNAjiyLkSUWkFpoCsEMEtpba1LpvPGy4nv46tZ9A20=";
    fetchSubmodules = true;
  };

  patches = [
  ];

  postPatch = ''
        mkdir -p src/private
        
        # Disable dependency fetching since we provide all dependencies through Nix
        # Comment out all populate() calls in various CMake files (including wxwidgets)
        sed -i 's/^populate(/# populate(/g' buildscripts/cmake/SetupDependencies.cmake
        sed -i 's/^populate(/# populate(/g' buildscripts/cmake/SetupDevEnvironment.cmake
        
        # Also disable any cmake_language(CALL *_Populate) calls
        find . -name "*.cmake" -type f -exec sed -i 's/cmake_language(CALL \(.*\)_Populate)/# cmake_language(CALL \1_Populate)/g' {} \;
        
        # And any other populate calls that might be indented
        find . -name "*.cmake" -type f -exec sed -i 's/^[[:space:]]*populate(/# populate(/g' {} \;
        
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
        
        # Disable modules that try to fetch dependencies or need special CMake targets
        echo "# Disabled - using system libraries" > src/au3wrap/lv2sdk/CMakeLists.txt
        echo "# Disabled - VST3 support is off" > src/au3wrap/vst3/CMakeLists.txt
        echo "# Disabled - using system portaudio" > src/au3wrap/thirdparty/portmixer/CMakeLists.txt
        
        # Disable LV2 and VST3 libraries in au3 (missing dependencies: zix, vst3sdk)
        echo "# Disabled - missing zix dependency" > au3/libraries/lib-lv2/CMakeLists.txt
        echo "# Disabled - VST3 support is off" > au3/libraries/lib-vst3/CMakeLists.txt
        
        # Disable VST in muse_framework
        echo "# Disabled - VST3 support is off" > muse_framework/framework/vst/CMakeLists.txt
        
        # Disable LV2 and VST effects modules
        echo "# Disabled - LV2 support is off" > src/effects/lv2/CMakeLists.txt
        echo "# Disabled - VST support is off" > src/effects/vst/CMakeLists.txt
        
        # Remove LV2 and VST3 source files from au3wrap CMakeLists.txt
        sed -i '/lib-lv2.*\.cpp/d' src/au3wrap/CMakeLists.txt
        sed -i '/lib-lv2.*\.h/d' src/au3wrap/CMakeLists.txt
        sed -i '/lib-vst3.*\.cpp/d' src/au3wrap/CMakeLists.txt
        sed -i '/lib-vst3.*\.h/d' src/au3wrap/CMakeLists.txt
        
        # Remove disabled libraries from main audacity app link list
        sed -i '/effects_lv2/d' src/app/CMakeLists.txt
        sed -i '/effects_vst/d' src/app/CMakeLists.txt
        
        # Make sure effects_base is linked (it contains AbstractViewLauncher needed by effects_builtin)
        # Add it to the target_link_libraries if not already there
        if ! grep -q "effects_base" src/app/CMakeLists.txt; then
            sed -i '/target_link_libraries.*audacity/a\    effects_base' src/app/CMakeLists.txt
        fi
        
        # Remove disabled libraries from au3wrap link lists
        sed -i '/set(AU3_LINK.*lv2sdk)/d' src/au3wrap/CMakeLists.txt
        sed -i '/set(AU3_LINK.*vst_sdk_3)/d' src/au3wrap/CMakeLists.txt
        sed -i '/portmixer/d' src/au3wrap/au3defs.cmake
        
        # Comment out LV2 and VST module initialization in main.cpp since we disabled them
        sed -i 's/\(.*Lv2EffectsModule.*\)/\/\/ \1 \/\/ Disabled by Nix build/g' src/app/main.cpp
        sed -i 's/\(.*VstEffectsModule.*\)/\/\/ \1 \/\/ Disabled by Nix build/g' src/app/main.cpp
        
        # Also comment out includes for these modules
        sed -i 's/\(#include.*lv2.*effectsmodule.*\)/\/\/ \1 \/\/ Disabled by Nix build/gi' src/app/main.cpp
        sed -i 's/\(#include.*vst.*effectsmodule.*\)/\/\/ \1 \/\/ Disabled by Nix build/gi' src/app/main.cpp
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace au3/libraries/lib-files/FileNames.cpp \
      --replace-fail /usr/include/linux/magic.h ${linuxHeaders}/include/linux/magic.h
  '';

  nativeBuildInputs = [
    cmake
    gettext
    pkg-config
    python3
    makeWrapper
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
    wxGTK32
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib # for portaudio
    at-spi2-core
    dbus
    libepoxy
    libXdmcp
    libXtst
    libpthreadstubs
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
    "-Daudacity_has_vst3=Off"
    "-Daudacity_has_crashreports=Off"

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
    "-DMUE_COMPILE_USE_SYSTEM_HARFBUZZ=ON"
    "-DMUE_COMPILE_USE_SYSTEM_FREETYPE=ON"

    # Try to use system wxWidgets
    "-DwxWidgets_CONFIG_EXECUTABLE=${wxGTK32}/bin/wx-config"
    "-DwxWidgets_wxrc_EXECUTABLE=${wxGTK32}/bin/wxrc"

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
