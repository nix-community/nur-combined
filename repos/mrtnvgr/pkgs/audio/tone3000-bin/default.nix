# Took parts from https://github.com/Warpledge/nixos-config/blob/fe8a3b3cf5b61b29b4d0f6e90e52a28d633bf889/shared/modules/home-manager/programs/creative/guitar.nix
# Thank you, @Warpledge :)

{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  alsa-lib,
  fontconfig,
  freetype,
  libx11,
  webkitgtk_4_1,
  libsoup_3,
  glib,
  gtk3,
  curl,
  libGL,
  libxcursor,
  libxext,
  libxinerama,
  libxrandr,
  libxscrnsaver,
  makeSetupHook,
  patchelf,
  writeText,
}:
let
  # auto-patchelf only adds its --runtime-dependencies to *executables*; the
  # plugin bundles are .so/.clap and would never get the WebKitGTK / GTK /
  # curl lib dirs. This hook runs after auto-patchelf in the postFixup pass
  # (hooks appended later in postFixupHooks run later) and appends the dlopen
  # lib dirs to every ELF artefact's rpath. Without them the WebView silently
  # renders blank on NixOS.
  dlopenRpathHook = makeSetupHook {
    name = "tone3000-dlopen-rpath-hook";
    propagatedBuildInputs = [ patchelf ];
  } (writeText "tone3000-dlopen-rpath-hook.sh" ''
    extendTone3000Rpath() {
      local rpath="${lib.makeSearchPathOutput "lib" "lib" [ gtk3 webkitgtk_4_1 alsa-lib curl freetype fontconfig libGL ]}"
      find "$out" -type f \
        \( -name '*.so' -o -name '*.clap' -o -name 'TONE3000' \) \
        -exec patchelf --add-rpath "$rpath" {} \; 2>/dev/null || true
    }
    postFixupHooks+=(extendTone3000Rpath)
  '');
in
stdenv.mkDerivation (finalAttrs: {
  pname = "tone3000-bin";
  version = "0.0.4";

  src = fetchzip {
    url = "https://github.com/tone-3000/tone3000-plugin/releases/download/v${finalAttrs.version}/TONE3000-v${finalAttrs.version}-linux-x64.tar.gz";
    hash = "sha256-EvvK/3gCV6mCVtW8tWGAZZdF1BLDXDRe5lcZveD2jdw=";
  };

  nativeBuildInputs = [ autoPatchelfHook dlopenRpathHook ];

  buildInputs = [
    alsa-lib
    fontconfig
    freetype
    stdenv.cc.cc
    libx11
    gtk3
    webkitgtk_4_1
    curl
  ];

  dontConfigure = true;
  dontBuild = true;
  doCheck = false;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/lv2 $out/lib/clap $out/lib/vst3 $out/share/tone3000/presets
    install -Dm755 TONE3000 $out/bin/TONE3000
    install -Dm644 TONE3000.clap $out/lib/clap/TONE3000.clap
    cp -r TONE3000.lv2 $out/lib/lv2/
    cp -r TONE3000.vst3 $out/lib/vst3/
    cp factory-presets/*.t3kpreset $out/share/tone3000/presets/

    runHook postInstall
  '';

  # meta = with lib; {
  #   description = "JUCE-based audio plugin that loads Neural Amp Modeler captures and IRs from TONE3000";
  #   homepage = "https://www.tone3000.com/plugin";
  #   license = licenses.mit;
  #   platforms = [ "x86_64-linux" ];
  #   mainProgram = "TONE3000";
  #   sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  #   maintainers = [ ];
  # };
})
