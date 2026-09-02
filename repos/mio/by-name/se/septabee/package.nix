{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  p7zip,
  libpng,
  zlib,
  vulkan-loader,
  freetype,
  pipewire,
  libx11,
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
    copyDesktopItems
    makeWrapper
    p7zip
  ];

  # autoPatchelfHook resolves these against the built package's ELF binaries.
  buildInputs = [
    libpng
    zlib
    vulkan-loader
    freetype
    pipewire
    libx11
    (lib.getLib stdenv.cc.cc) # libstdc++.so.6, libgcc_s.so.1
    lilv
  ];

  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    ${p7zip}/bin/7z x "$src" -o"unpacked"
    runHook postUnpack
  '';

  # All three binaries (septabee, septabee-sounds, septabee-watchdawg) live
  # together in the upstream archive. The main binary discovers companions via
  # /proc/self/exe and execlp, so they must be findable on PATH or alongside
  # the launcher. We install everything into $out/libexec/septabee/ and expose
  # only the main launcher via a makeWrapper wrapper that prepends the libexec
  # dir to PATH.
  installPhase = ''
    runHook preInstall

    cd unpacked/linux

    libexec="$out/libexec/septabee"
    share="$out/share/septabee"

    install -Dm755 septabee            "$libexec/septabee"
    install -Dm755 septabee-sounds     "$libexec/septabee-sounds"
    install -Dm755 septabee-watchdawg  "$libexec/septabee-watchdawg"

    install -Dm644 septabee.data       "$share/septabee.data"
    install -Dm644 theme.bee           "$share/theme.bee"
    install -Dm644 "Inter-VariableFont_opsz,wght.ttf" \
      "$share/Inter-VariableFont_opsz,wght.ttf"
    install -Dm644 LiberationSerif-Regular.ttf \
      "$share/LiberationSerif-Regular.ttf"

    makeWrapper "$libexec/septabee" "$out/bin/septabee" \
      --prefix PATH : "$libexec"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "septabee";
      desktopName = "Septabee";
      comment = "Septabee personal productivity app";
      exec = "septabee";
      icon = "septabee";
      categories = [ "Utility" ];
      terminal = false;
      startupNotify = true;
    })
  ];

  meta = {
    description = "Septabee — personal productivity desktop app";
    homepage = "https://septabee.nekoweb.org/";
    downloadPage = "https://septabee.nekoweb.org/important_stuff/SEPTABEE_DOWNLOADS/version_B/septabee_linux_B_T1.7z";
    license = lib.licenses.unfree;
    mainProgram = "septabee";
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
