{ lib
, stdenv
, autoPatchelfHook
, dpkg
, fetchurl
, libayatana-appindicator
, openssl
, libsoup_3
, xdotool
, webkitgtk_4_1
, wrapGAppsHook3
}:
stdenv.mkDerivation rec {
  pname = "openai-translator";
  version = "0.4.32";
  preferLocalBuild = true;

  src = fetchurl {
    url = "https://github.com/openai-translator/openai-translator/releases/download/v${version}/OpenAI.Translator_${version}_amd64.deb";
    hash = "sha256-RjysU72MFeRbIrJh8s8egVLWcSGxGlTNOBd+4wB0XeU=";
  };

  nativeBuildInputs = [
    dpkg
    wrapGAppsHook3
    autoPatchelfHook
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

  installPhase = ''
    runHook preInstall

    dpkg-deb -x $src $out
    mv $out/usr/* $out
    rmdir $out/usr

    runHook postInstall
  '';

  meta = {
    description = "Cross-platform desktop application for translation based on ChatGPT API";
    homepage = "https://github.com/openai-translator/openai-translator";
    changelog = "https://github.com/openai-translator/openai-translator/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "app";
    maintainers = with lib.maintainers; [ kwaa ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
