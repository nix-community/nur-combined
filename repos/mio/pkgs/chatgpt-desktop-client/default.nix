{
  lib,
  stdenv,
  fetchFromGitHub,
  makeBinaryWrapper,
  copyDesktopItems,
  makeDesktopItem,
  electron,
}:

stdenv.mkDerivation rec {
  pname = "chatgpt-desktop-client";
  version = "1.0.1-unstable-2025-12-06";

  src = fetchFromGitHub {
    owner = "git-aniket";
    repo = "chatgpt-desktop-client";
    rev = "d02c7e4e7adc53fb42e58c44622b23efa0aed04f";
    hash = "sha256-HMr9cZ7aniuR8kaGiD3u7Hwjk/FaVyZNE0+1xrJJJz0=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    copyDesktopItems
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "chatgpt-desktop-client";
      desktopName = "ChatGPT Desktop";
      comment = "A simple and efficient desktop client for ChatGPT";
      exec = "chatgpt-desktop-client";
      icon = "chatgpt-desktop-client";
      categories = [
        "Network"
        "Utility"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/chatgpt-desktop-client
    cp -r . $out/share/chatgpt-desktop-client

    # Install icons
    mkdir -p $out/share/icons/hicolor/512x512/apps
    install -Dm644 assets/icon.png $out/share/icons/hicolor/512x512/apps/chatgpt-desktop-client.png

    makeWrapper ${electron}/bin/electron $out/bin/chatgpt-desktop-client \
      --add-flags "$out/share/chatgpt-desktop-client" \
      --add-flags "--enable-features=UseOzonePlatform" \
      --add-flags "--ozone-platform=wayland"

    runHook postInstall
  '';

  meta = {
    description = "A simple and efficient desktop client for ChatGPT";
    homepage = "https://github.com/git-aniket/chatgpt-desktop-client";
    license = lib.licenses.isc;
    mainProgram = "chatgpt-desktop-client";
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
  };
}
