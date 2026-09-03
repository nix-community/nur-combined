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
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tone3000-bin";
  version = "0.0.4";

  src = fetchzip {
    url = "https://github.com/tone-3000/tone3000-plugin/releases/download/v${finalAttrs.version}/TONE3000-v${finalAttrs.version}-linux-x64.tar.gz";
    hash = "sha256-EvvK/3gCV6mCVtW8tWGAZZdF1BLDXDRe5lcZveD2jdw=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    fontconfig
    freetype
    stdenv.cc.cc
    libx11
  ];

  appendRunpaths =
    (map (p: "${lib.getLib p}/lib") [
      webkitgtk_4_1
      libsoup_3
      glib
      gtk3
      curl
      libGL
      libxcursor
      libxext
      libxinerama
      libxrandr
      libxscrnsaver
    ])
    ++ ["/run/opengl-driver/lib"];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/lv2 $out/lib/clap $out/lib/vst3 $out/share/tone3000/presets
    install -Dm755 TONE3000 $out/bin/TONE3000
    install -Dm644 TONE3000.clap $out/lib/clap/TONE3000.clap
    cp -r TONE3000.lv2 $out/lib/lv2/
    cp -r TONE3000.vst3 $out/lib/vst3/
    cp factory-presets/*.t3kpreset $out/share/tone3000/presets/
    install -Dm644 tone3000.png $out/share/icons/hicolor/512x512/apps/tone3000.png

    runHook postInstall
  '';
})
