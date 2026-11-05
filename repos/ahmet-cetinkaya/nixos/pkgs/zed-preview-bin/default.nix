{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  fontconfig,
  glib,
  glibc,
  libxcb,
  libxkbcommon,
  libX11,
  openssl,
  sqlite,
  vulkan-loader,
  wayland,
  zlib,
}: let
  pname = "zed-preview-bin";
  version = "1.28.0-pre";
  runtimeLibs = [
    alsa-lib
    fontconfig
    glib
    glibc
    libxcb
    libxkbcommon
    libX11
    openssl
    sqlite
    vulkan-loader
    wayland
    zlib
    stdenv.cc.cc.lib
  ];
  src =
    if stdenvNoCC.hostPlatform.system == "x86_64-linux"
    then
      fetchurl {
        url = "https://github.com/zed-industries/zed/releases/download/v${version}/zed-linux-x86_64.tar.gz";
        sha256 = "7091d7e45c1bd1ca920abd34e3446cefafde6bc5bf780c12a326cce18050a4eb";
      }
    else if stdenvNoCC.hostPlatform.system == "aarch64-linux"
    then
      fetchurl {
        url = "https://github.com/zed-industries/zed/releases/download/v${version}/zed-linux-aarch64.tar.gz";
        sha256 = "3e067395366f7b1fbde7dcbef4d08290e769d1411b64e4145ff8965e7f620608";
      }
    else throw "Unsupported system for ${pname}: ${stdenvNoCC.hostPlatform.system}";
in
  stdenvNoCC.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = runtimeLibs;

    sourceRoot = "zed-preview.app";

    installPhase = ''
      runHook preInstall

      install -d "$out/bin" "$out/lib/zed" "$out/share/applications" "$out/share/licenses/zed-preview" "$out/share/icons/hicolor/512x512/apps"

      cp -r "libexec" "$out/lib/zed/"
      cp -r "share" "$out/lib/zed/"
      install -Dm755 "bin/zed" "$out/lib/zed/bin/zed"

      install -Dm644 "licenses.md" "$out/share/licenses/zed-preview/licenses.md"
      install -Dm644 "share/icons/hicolor/512x512/apps/zed.png" "$out/share/icons/hicolor/512x512/apps/zed-preview.png"

      cp "share/applications/dev.zed.Zed-Preview.desktop" "$out/share/applications/dev.zed.Zed-Preview.desktop"
      substituteInPlace "$out/share/applications/dev.zed.Zed-Preview.desktop" \
        --replace-fail "Exec=zed" "Exec=zeditor" \
        --replace-fail "Icon=zed" "Icon=zed-preview"

      makeWrapper "$out/lib/zed/libexec/zed-editor" "$out/bin/zed" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"
      makeWrapper "$out/lib/zed/libexec/zed-editor" "$out/bin/zeditor" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"

      runHook postInstall
    '';

    meta = with lib; {
      description = "A high-performance, multiplayer code editor (preview binary)";
      homepage = "https://zed.dev";
      license = with licenses; [
        gpl3Plus
        agpl3Plus
        asl20
      ];
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      mainProgram = "zed";
      maintainers = ["Ahmet Çetinkaya <contact@ahmetcetinkaya.me>"];
    };
  }
