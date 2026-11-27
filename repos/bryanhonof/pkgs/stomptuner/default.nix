{
  lib,
  stdenv,
  fetchFromGitHub,

  pkg-config,
  git,
  cairo,
  fftw,
  fftwFloat,
  lv2,
  liblo,
  jack2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "StompTuner";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "brummer10";
    repo = "StompTuner";
    fetchSubmodules = true;
    rev = "v${finalAttrs.version}";
    hash = "sha256-ChUlmD3XjAw1Uycchm2i7wnNSo8a9cfVC7+kl5Qwh/E=";
  };

  postPatch = ''
    patchShebangs dpf/utils
  ''
  # JackBridge dlopens JACK by bare name; nothing puts jack2 on dyld's path.
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace dpf/distrho/src/jackbridge/JackBridge.cpp \
      --replace-fail '"libjack.dylib"' '"${lib.getLib jack2}/lib/libjack.dylib"'
  '';

  nativeBuildInputs = [
    pkg-config
    git
    fftw
    fftwFloat
  ];

  buildInputs = [
    cairo
    liblo
    lv2
    jack2
  ];

  makeFlags = [
    "SKIP_NATIVE_AUDIO_FALLBACK8=true"
    "BUILD_AU=false"
  ];

  installFlags = [
    "PREFIX="
    "DESTDIR=${placeholder "out"}"
  ];

  meta = with lib; {
    description = "Multi-format LV2|VST2|VST3|CLAP|AU multi-arch Linux|macOS|Windows Strobe Tuner using the DISTRHO Plugin Framework";
    homepage = "https://github.com/brummer10/StompTuner";
    license = licenses.gpl3;
    maintainers = with maintainers; [ bryanhonof ];
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "stomptuner";
  };
}
// lib.optionalAttrs stdenv.hostPlatform.isDarwin {
  # On darwin DPF emits VST2/CLAP as bundles, which upstream's install rule
  # still looks for as plain .dylib files.
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/{lv2,vst,vst3,clap} $out/Applications $out/bin
    cp -r bin/stomptuner.lv2 $out/lib/lv2/
    cp -r bin/stomptuner.vst $out/lib/vst/
    cp -r bin/stomptuner.vst3 $out/lib/vst3/
    cp -r bin/stomptuner.clap $out/lib/clap/
    cp -r bin/stomptuner.app $out/Applications/
    ln -s $out/Applications/stomptuner.app/Contents/MacOS/stomptuner $out/bin/stomptuner
    runHook postInstall
  '';
})
