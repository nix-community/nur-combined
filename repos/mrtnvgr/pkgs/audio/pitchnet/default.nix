{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchzip,
  cmake,
  ninja,
  pkg-config,
  alsa-lib,
  freetype,
  fontconfig,
  libGL,
  libx11,
  libxcursor,
  libxcomposite,
  libxext,
  libxinerama,
  libxrandr,
  libxrender,
  libjack2,
  copyDesktopItems,
  makeDesktopItem,
  patchelf,
}:

let
  onnxruntime = fetchzip {
    url = "https://github.com/microsoft/onnxruntime/releases/download/v1.19.2/onnxruntime-linux-x64-1.19.2.tgz";
    hash = "sha256-tnOg0KwlPBQl2r/Dli+MwhHB/88e4a/Ird2nidIGwEg=";
  };

  gameModels = fetchzip {
    url = "https://github.com/openvpi/GAME/releases/download/v1.0.3/GAME-1.0.3-small-onnx.zip";
    hash = "sha256-WXxi8XXraLwnt0g41MI41U7/Oh8dWf9Z1+pp71PRVi0=";
  };

  runtimeDependencies = [
    libGL
    libx11
    libxcursor
    libxcomposite
    libxext
    libxinerama
    libxrandr
    libxrender
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "pitchnet";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "SessionLoops";
    repo = "PitchNet";
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-tXcVXo0OViCGJun1HF2QPtZQMoXwAqrKtbBpir101f0=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    copyDesktopItems
    patchelf
  ];

  buildInputs = [
    alsa-lib
    freetype
    fontconfig
    libx11
    libxcursor
    libxcomposite
    libxext
    libxinerama
    libxrandr
    libxrender
    libjack2
  ];

  postPatch = ''
    mkdir -p Resources/models/GAME
    cp ${gameModels}/*.onnx ${gameModels}/config.json Resources/models/GAME/

    mkdir -p build/_deps/onnxruntime-1.19.2-src
    cp -r ${onnxruntime}/include ${onnxruntime}/lib build/_deps/onnxruntime-1.19.2-src/

    substituteInPlace CMakeLists.txt \
      --replace-fail "juce::juce_recommended_lto_flags" ""
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 PitchNet_artefacts/Release/PitchNet $out/bin/PitchNet

    mkdir -p $out/lib/vst3 $out/lib/pitchnet
    cp -r PitchNetPlugin_artefacts/Release/VST3/PitchNet.vst3 $out/lib/vst3/
    cp -P ${onnxruntime}/lib/libonnxruntime.so* ${onnxruntime}/lib/libonnxruntime_providers_shared.so $out/lib/pitchnet/

    cp -r ../Resources $out/Resources

    install -Dm644 ../Resources/images/icon.png $out/share/icons/hicolor/512x512/apps/pitchnet.png

    for f in $out/bin/PitchNet $out/lib/vst3/PitchNet.vst3/Contents/x86_64-linux/PitchNet.so; do
      patchelf --set-rpath "$(patchelf --print-rpath "$f" | sed -E 's|[^:]*/build[^:]*:?||g')" "$f"
    done

    runHook postInstall
  '';

  postFixup = ''
    patchelf --add-rpath "${lib.makeLibraryPath runtimeDependencies}:$out/lib/pitchnet" $out/bin/PitchNet
    patchelf --add-rpath "${lib.makeLibraryPath runtimeDependencies}:$out/lib/pitchnet" $out/lib/vst3/PitchNet.vst3/Contents/x86_64-linux/PitchNet.so
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "pitchnet";
      desktopName = "PitchNet";
      genericName = "Pitch editor";
      comment = "Neural pitch editor with real-time vocoder resynthesis";
      exec = "PitchNet";
      icon = "pitchnet";
      terminal = false;
      categories = [
        "AudioVideo"
        "Audio"
        "Music"
      ];
    })
  ];

  meta = {
    description = "Lightweight pitch editor with neural pitch detection and vocoder resynthesis";
    homepage = "https://github.com/SessionLoops/PitchNet";
    license = lib.licenses.agpl3Only;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "PitchNet";
  };
})
