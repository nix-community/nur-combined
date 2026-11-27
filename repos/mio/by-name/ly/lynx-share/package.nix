{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  cmake,
  ninja,
  pkg-config,
  alsa-lib,
  curl,
  fontconfig,
  freetype,
  libGL,
  libX11,
  libXcomposite,
  libXcursor,
  libXext,
  libXfixes,
  libXinerama,
  libXrandr,
  libXrender,
  libjack2,
  makeWrapper,
  pipewire,
  unzip,
  cctools,
  rcodesign,
  python3,
  nix,
  nix-update,
  git,
  writeShellApplication,
}:

let
  version = "0.1.31.2-unstable-2026-11-26";

  # LYNX applies a large compatibility patch set to JUCE 8.0.4's sources.
  juceVersion = "8.0.4";
  juceHash = "sha256-iAueT+yHwUUHOzqfK5zXEZQ0GgOKJ9q9TyRrVfWdewc=";
  juce = fetchFromGitHub {
    owner = "juce-framework";
    repo = "JUCE";
    tag = juceVersion;
    hash = juceHash;
  };

  # Stem extraction loads this exact ONNX Runtime release at run time.
  onnxRuntimeVersion = "1.23.2";
  onnxRuntimeHash = "sha256-Jf4XL3/N808rWwLIuZf2uIq8KClWhJ1K9DNa8j0MTko=";
  onnxRuntime = fetchurl {
    url = "https://api.nuget.org/v3-flatcontainer/microsoft.ml.onnxruntime/${onnxRuntimeVersion}/microsoft.ml.onnxruntime.${onnxRuntimeVersion}.nupkg";
    hash = onnxRuntimeHash;
  };

  isLinux = stdenv.hostPlatform.isLinux;
  isDarwin = stdenv.hostPlatform.isDarwin;
  isAarch64 = stdenv.hostPlatform.isAarch64;

  linuxBuildInputs = [
    alsa-lib
    curl
    fontconfig
    freetype
    libGL
    libX11
    libXcomposite
    libXcursor
    libXext
    libXfixes
    libXinerama
    libXrandr
    libXrender
    libjack2
    pipewire
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "lynx-share";
  inherit version;

  src = fetchFromGitHub {
    owner = "Ka1-S";
    repo = "LYNX-SHARE";
    rev = "211e6e78bc950fcc08509d18983d411e08ff91b0";
    hash = "sha256-VS4zP/u8YMYmkTb+hC5UbtfmQLwcCjgQz27675ErYTY=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    unzip
    python3
  ]
  ++ lib.optionals isLinux [ makeWrapper ]
  ++ lib.optionals isDarwin [
    cctools
    rcodesign
  ];

  buildInputs = lib.optionals isLinux linuxBuildInputs;

  strictDeps = true;
  cmakeBuildType = "Release";

  # JUCE is fetched at configure time upstream. Make the pinned checkout writable
  # locally because LYNX's compatibility patches edit JUCE's source files.
  preConfigure = ''
    cp -R ${juce} juce-src
    chmod -R u+w juce-src
  '';

  # Use upstream's documented CMake commands directly so FetchContent can use
  # the writable pinned JUCE checkout instead of trying to fetch it in the sandbox.
  configurePhase = ''
    runHook preConfigure

    cmake -S . -B build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DFETCHCONTENT_SOURCE_DIR_JUCE="$PWD/juce-src" \
      -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
      -DLYNX_BUILD_APP=ON \
      -DLYNX_LTO=OFF

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    cmake --build build --target LYNX --parallel "''${NIX_BUILD_CORES:-1}"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/share/doc/lynx-share"
    cp LICENSE THIRD_PARTY.md PRIVACY.md "$out/share/doc/lynx-share/"

    ${lib.optionalString isDarwin ''
      mkdir -p "$out/Applications" "$out/bin" "$TMPDIR/onnx"
      cp -a build/LYNX_artefacts/Release/LYNX.app "$out/Applications/"
      mkdir -p "$out/Applications/LYNX.app/Contents/Frameworks"

      unzip -j ${onnxRuntime} 'runtimes/osx-arm64/native/libonnxruntime.dylib' -d "$TMPDIR/onnx/arm64"
      unzip -j ${onnxRuntime} 'runtimes/osx-x64/native/libonnxruntime.dylib' -d "$TMPDIR/onnx/x86_64"
      lipo -create \
        "$TMPDIR/onnx/arm64/libonnxruntime.dylib" \
        "$TMPDIR/onnx/x86_64/libonnxruntime.dylib" \
        -output "$out/Applications/LYNX.app/Contents/Frameworks/libonnxruntime.${onnxRuntimeVersion}.dylib"

      ln -s "$out/Applications/LYNX.app/Contents/MacOS/LYNX" "$out/bin/LYNX"
    ''}

    ${lib.optionalString isLinux ''
      install -m755 build/LYNX_artefacts/Release/LYNX "$out/bin/LYNX"

      ${lib.optionalString isAarch64 ''
        unzip -j ${onnxRuntime} 'runtimes/linux-arm64/native/libonnxruntime.so' -d "$TMPDIR/onnx"
      ''}
      ${lib.optionalString (!isAarch64) ''
        unzip -j ${onnxRuntime} 'runtimes/linux-x64/native/libonnxruntime.so' -d "$TMPDIR/onnx"
      ''}
      install -m755 "$TMPDIR/onnx/libonnxruntime.so" "$out/bin/libonnxruntime.so.${onnxRuntimeVersion}"

      wrapProgram "$out/bin/LYNX" \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath linuxBuildInputs}

      install -Dm644 resources/linux/lynx.desktop \
        "$out/share/applications/com.lynx_share.LYNX.desktop"
      install -Dm644 resources/linux/lynx-mime.xml \
        "$out/share/mime/packages/lynx-mime.xml"
      mkdir -p "$out/share/metainfo"
      substitute resources/linux/com.lynx_share.LYNX.appdata.xml \
        "$out/share/metainfo/com.lynx_share.LYNX.appdata.xml" \
        --replace-fail '@VERSION@' '${version}' \
        --replace-fail '@DATE@' '2026-11-25'
      cp -R resources/linux/icons/hicolor "$out/share/icons/"
      install -Dm644 resources/lynx_icon_256.png \
        "$out/share/icons/hicolor/256x256/apps/lynx.png"
    ''}

    runHook postInstall
  '';

  # Fixup strips Mach-O files, which invalidates the framework's and linker's
  # signatures. rcodesign is a sandbox-safe replacement for Apple's codesign.
  postFixup = lib.optionalString isDarwin ''
    chmod -R u+w "$out/Applications/LYNX.app"
    ${lib.getExe rcodesign} sign "$out/Applications/LYNX.app"
  '';

  passthru.updateScript = writeShellApplication {
    name = "update-lynx-share";
    runtimeInputs = [
      python3
      nix
      nix-update
      git
    ];
    text = ''
      export UPDATE_NIX_ATTR_PATH="lynx-share"
      exec python3 ${./update.py} "$@"
    '';
  };

  meta = {
    description = "LYNX SHARE lightweight digital audio workstation";
    longDescription = ''
      LYNX SHARE is an open-source digital audio workstation with pattern,
      clip-launch and simple layouts. It imports FL Studio, Ableton Live,
      DAWproject and several other project formats and hosts VST3, CLAP and
      LV2 plugins.
    '';
    homepage = "https://lynx-share.com";
    downloadPage = "https://github.com/Ka1-S/LYNX-SHARE/releases";
    changelog = "https://github.com/Ka1-S/LYNX-SHARE/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.agpl3Plus;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    mainProgram = "LYNX";
  };
})
