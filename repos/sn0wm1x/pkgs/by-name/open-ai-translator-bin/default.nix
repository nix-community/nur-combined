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
  pname = "open-ai-translator";
  version = "0.4.33";

  src = fetchurl {
    url = "https://github.com/openai-translator/openai-translator/releases/download/v${version}/open-ai-translator_${version}_amd64.deb";
    hash = "sha256-3WwIKM1dM9Vf5hKXtUlq2NfBTreucwhPeBVnMj+M8LE=";
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
    cp -r usr/bin/${pname} $out/bin/${pname}

    mkdir -p $out/share/{icons,${pname}}
    cp -r usr/lib/${pname}/resources $out/share/${pname}
    cp -r usr/share/icons $out/share

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
    mainProgram = "open-ai-translator";
    maintainers = with lib.maintainers; [ kwaa ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
