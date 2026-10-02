{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  cmake,
  pkg-config,
  writableTmpDirAsHomeHook,
  copyDesktopItems,
  makeDesktopItem,
  patchelf,
  alsa-lib,
  libjack2,
  libx11,
  libxext,
  libxrandr,
  libxcursor,
  libxinerama,
  libxrender,
  libxcomposite,
  libxfixes,
  libxi,
  fontconfig,
  curl,
}:

let
  # Everything the CMake build fetches with CPM/FetchContent is pinned to a
  # source here and handed to CMake through FETCHCONTENT_SOURCE_DIR_<NAME>, so
  # the sandbox never needs network access.
  freetypeSrc = fetchFromGitHub {
    owner = "freetype";
    repo = "freetype";
    tag = "VER-2-13-3";
    hash = "sha256-4l90lDtpgm5xlh2m7ifrqNy373DTRTULRkAzicrM93c=";
  };

  juce = fetchFromGitHub {
    owner = "juce-framework";
    repo = "JUCE";
    tag = "9.0.3";
    hash = "sha256-eB5HvUiKXRAp53EApiX0jGNhXVtt83zD9TaNOhdQIjc=";
  };

  googletest = fetchFromGitHub {
    owner = "google";
    repo = "googletest";
    tag = "v1.15.2";
    hash = "sha256-1OJ2SeSscRBNr7zZ/a8bJGIqAnhkg45re0j3DtPfcXM=";
  };

  clap-juce-extensions = fetchFromGitHub {
    owner = "free-audio";
    repo = "clap-juce-extensions";
    rev = "c1a5ad025f95d01e03267857fa8276ebeed16500";
    fetchSubmodules = true;
    hash = "sha256-P8rLNI9fXGU8yxXXdOkRD/+T3AMd3zdRM8mHp62dEmA=";
  };

  cpm = fetchurl {
    url = "https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.40.2/CPM.cmake";
    hash = "sha256-yM3DLAOBZTjOInge1ylk3IZLKjSjENO3EEgSpcotg10=";
  };

  # JUCE resolves X11, JACK and libcurl with dlopen at runtime, so the loader
  # rpath has to point at them; FreeType is linked statically and ALSA and
  # fontconfig are picked up by the standard fixup, but they are all listed
  # here so the plugin also works under hosts with a minimal environment.
  runtimeDependencies = [
    alsa-lib
    libjack2
    fontconfig
    libx11
    libxext
    libxrandr
    libxcursor
    libxinerama
    libxrender
    libxcomposite
    libxfixes
    libxi
    curl
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "tone3000";
  version = "0.0.11";

  src = fetchFromGitHub {
    owner = "tone-3000";
    repo = "tone3000-plugin";
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-KkDFROBtHi1f1iHs7g5JtIqqRD+WqUeKoZz3h1oybfM=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    writableTmpDirAsHomeHook
    copyDesktopItems
    patchelf
  ];

  buildInputs = [
    alsa-lib
    libjack2
    libx11
    libxext
    libxrandr
    libxcursor
    libxinerama
    libxrender
    libxcomposite
    libxfixes
    libxi
    fontconfig
    curl
  ];

  postPatch = ''
    # CMakeLists pulls CPM.cmake off the network; seed the exact file it
    # expects so the configure step stays offline.
    mkdir -p libs/cpm
    cp ${cpm} libs/cpm/CPM_0.40.2.cmake

    # Look up the shipped factory presets in this store path instead of the
    # hardcoded /usr/share distro location.
    substituteInPlace plugin/src/PresetManager.cpp \
      --replace-fail \
        'return juce::File("/usr/share/TONE3000/Presets/Factory");' \
        'return juce::File("${placeholder "out"}/share/TONE3000/Presets/Factory");'

    # Visual Studio source grouping only; it rejects the clap-juce-extensions
    # sources that live outside the project tree.
    substituteInPlace plugin/CMakeLists.txt \
      --replace-fail \
        'source_group(TREE ''${CMAKE_CURRENT_SOURCE_DIR}/..)' \
        '# source_group(TREE ...) omitted: JUCE sources are supplied out-of-tree'
  '';

  cmakeFlags = [
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_FREETYPE" "${freetypeSrc}")
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_GOOGLETEST" "${googletest}")
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_CLAP-JUCE-EXTENSIONS" "${clap-juce-extensions}")
    (lib.cmakeBool "BUILD_AAX" false)
  ];

  # The root CMakeLists applies configure-time source patches to the copy of
  # JUCE under libs/juce, so it has to live inside the project tree. Fetching
  # it there (instead of pointing FETCHCONTENT at the read-only store path)
  # also keeps source_group()/Visual Studio happy.
  preConfigure = ''
    cp -r ${juce} libs/juce
    chmod -R u+w libs/juce
    cmakeFlagsArray+=("-DFETCHCONTENT_SOURCE_DIR_JUCE=$PWD/libs/juce")
  '';

  env = {
    # JUCE is compiled here (not imported) with LTO; the NAM archive is linked
    # with --whole-archive, which needs fat LTO objects to combine. Same
    # workaround jc303 uses.
    NIX_CFLAGS_COMPILE = "-ffat-lto-objects";

    # Publishable OAuth client id baked into the official Linux release binary.
    # It is a public client id (not a secret) and the plugin needs it for
    # TONE3000 sign-in; the CMake build reads it from the environment.
    T3K_PUBLISHABLE_KEY = "t3k_pub__B8V_QGmV50ov2YWJzjqOxQE0q1-wURs";
  };

  # DspTests and the maintainer tools are not shipped; build only the plugin
  # and standalone targets so the test suite and its assets are left alone.
  buildPhase = ''
    runHook preBuild

    cmake --build . --target \
      TONE3000_Standalone \
      TONE3000_VST3 \
      TONE3000_LV2 \
      TONE3000_CLAP

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pushd plugin/TONE3000_artefacts/Release

    install -Dm755 Standalone/TONE3000 $out/bin/TONE3000

    mkdir -p $out/lib/vst3 $out/lib/lv2 $out/lib/clap
    cp -r VST3/TONE3000.vst3 $out/lib/vst3/
    cp -r LV2/TONE3000.lv2 $out/lib/lv2/
    install -m644 CLAP/TONE3000.clap $out/lib/clap/

    popd

    install -Dm644 ${finalAttrs.src}/resources/factory-presets/*.t3kpreset \
      -t $out/share/TONE3000/Presets/Factory
    install -Dm644 ${finalAttrs.src}/script/installer/linux/tone3000.png \
      $out/share/icons/hicolor/512x512/apps/tone3000.png

    runHook postInstall
  '';

  postFixup = ''
    for f in \
      $out/bin/TONE3000 \
      $out/lib/vst3/TONE3000.vst3/Contents/*/TONE3000.so \
      $out/lib/lv2/TONE3000.lv2/*.so \
      $out/lib/clap/TONE3000.clap
    do
      patchelf --add-rpath "${lib.makeLibraryPath runtimeDependencies}" "$f"
    done
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "tone3000";
      desktopName = "TONE3000";
      genericName = "Guitar amp and IR plugin";
      comment = "Play NAM captures and IRs from TONE3000";
      exec = "TONE3000";
      icon = "tone3000";
      terminal = false;
      categories = [
        "AudioVideo"
        "Audio"
        "Music"
      ];
      startupWMClass = "TONE3000";
    })
  ];

  meta = {
    description = "Audio plugin that loads Neural Amp Modeler captures and impulse responses from TONE3000";
    homepage = "https://github.com/tone-3000/tone3000-plugin";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.linux;
    mainProgram = "TONE3000";
  };
})
