{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  p7zip,
  libpng,
  zlib,
  vulkan-loader,
  freetype,
  pipewire,
  libx11,
  stdenv,
  lilv,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "septabee";
  version = "B-T1";

  src = fetchurl {
    url = "https://septabee.nekoweb.org/important_stuff/SEPTABEE_DOWNLOADS/version_B/septabee_linux_B_T1.7z";
    hash = "sha256-JlWmeDnMTjBNwLTADvSswbtfhJK6t1bu0xHkmBgLtvA=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    p7zip
  ];

  buildInputs = [
    libpng
    zlib
    vulkan-loader
    freetype
    pipewire
    libx11
    stdenv.cc.cc.lib # libstdc++
    lilv
  ];

  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    7z x "$src" -o"$(pwd)/unpacked"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    cd unpacked/linux

    install -Dm755 septabee           "$out/bin/septabee"
    install -Dm755 septabee-sounds    "$out/lib/septabee/septabee-sounds"
    install -Dm755 septabee-watchdawg "$out/lib/septabee/septabee-watchdawg"

    install -Dm644 septabee.data      "$out/share/septabee/septabee.data"
    install -Dm644 theme.bee          "$out/share/septabee/theme.bee"
    install -Dm644 "Inter-VariableFont_opsz,wght.ttf" \
      "$out/share/septabee/Inter-VariableFont_opsz,wght.ttf"
    install -Dm644 LiberationSerif-Regular.ttf \
      "$out/share/septabee/LiberationSerif-Regular.ttf"

    runHook postInstall
  '';

  meta = {
    description = "Septabee — personal productivity / bee-themed desktop app";
    homepage = "https://septabee.nekoweb.org/";
    downloadPage = "https://septabee.nekoweb.org/important_stuff/SEPTABEE_DOWNLOADS/version_B/septabee_linux_B_T1.7z";
    license = lib.licenses.unfree;
    mainProgram = "septabee";
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
