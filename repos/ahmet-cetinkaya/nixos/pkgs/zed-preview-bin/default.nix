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
  version = "1.13.0-pre";
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
        sha256 = "e65f48700b1877f4e7601e72d5ef1a5f804d53dec878b8175a67ce3dd24c31b7";
      }
    else if stdenvNoCC.hostPlatform.system == "aarch64-linux"
    then
      fetchurl {
        url = "https://github.com/zed-industries/zed/releases/download/v${version}/zed-linux-aarch64.tar.gz";
        sha256 = "cb506f915bbce7572383051568e393626434aa90b3c3784cf657d5091f594ed7";
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
