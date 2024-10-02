{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  copyDesktopItems,
  dpkg,
  wrapGAppsHook3,
  openssl,
  libsoup_3,
  xdotool,
  webkitgtk_4_1,
  libayatana-appindicator,
  makeDesktopItem,
}:

stdenv.mkDerivation rec {
  pname = "openai-translator";
  version = "0.4.32";

  src = fetchurl {
    url = "https://github.com/openai-translator/openai-translator/releases/download/v${version}/OpenAI.Translator_${version}_amd64.deb";
    hash = "sha256-RjysU72MFeRbIrJh8s8egVLWcSGxGlTNOBd+4wB0XeU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    dpkg
    wrapGAppsHook3
  ];

  buildInputs = [
    openssl
    libsoup_3
    xdotool
    webkitgtk_4_1
  ];

  runtimeDependencies = [
    libayatana-appindicator
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 usr/bin/app $out/bin/${pname}

    mkdir -p $out/share/${pname}
    cp -r usr/lib/app/resources $out/share/${pname}

    mkdir -p $out/share/icons/hicolor/{32x32,128x128,256x256@2}
    for size in 32x32 128x128 256x256@2; do
      install -Dm644 usr/share/icons/hicolor/$size/apps/app.png $out/share/icons/hicolor/$size/apps/${pname}.png
    done

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      desktopName = "OpenAI Translator";
      name = pname;
      exec = pname;
      icon = pname;
      comment = meta.description;
      terminal = false;
      categories = [ "Development" ];
    })
  ];

  meta = {
    description = "Cross-platform desktop application for translation based on ChatGPT API";
    homepage = "https://github.com/openai-translator/openai-translator";
    downloadPage = "https://github.com/openai-translator/openai-translator/releases";
    changelog = "https://github.com/openai-translator/openai-translator/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "openai-translator";
    maintainers = with lib.maintainers; [ kwaa ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
