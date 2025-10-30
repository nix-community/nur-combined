{
  system,
  fetchzip,
  stdenvNoCC,
  autoPatchelfHook,
  pkgs,
}: let
  platforms = {
    "x86_64-linux" = {
      url = "linux-x64";
      hash = "sha256-DZARH+bR5Rt/2esu9Cf/fHoxPl9xy4BXD1Vcwo3UIwM=";
      isMacOS = false;
    };
    "aarch-linux" = {
      url = "linux-arm64";
      hash = "sha256-9VU84ek7myn1svqq0XMUXIWFTKedpnIMiAjN3StODSI=";
      isMacOS = false;
    };
    "x86_64-darwin" = {
      url = "darwin-x64";
      hash = "sha256-FA4KsFOMy0s6F8pXBlA7UcgCHW7sPk1tZd/9ngkGQss=";
      isMacOS = true;
    };
    "aarch-darwin" = {
      url = "darwin-arm64";
      hash = "sha256-FK4w7+vMjhL8oXDWjIZ0cmFRohxH5qdux2TBedS/VoY=";
      isMacOS = true;
    };
  };
  platform = platforms.${toString system} or (throw "[nix-repository:lotion-bin] system not supported: ${toString system}");
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "lotion";
    version = "1.5.0";
    src = fetchzip {
      url = "https://github.com/puneetsl/lotion/releases/download/v${finalAttrs.version}/Lotion-${platform.url}-${finalAttrs.version}.zip";
      hash = platform.hash;
    };

    buildInputs = with pkgs; [
      libxcb
      vulkan-loader
      libx11
      libgcc
      libxrandr
      libxext
      cairo
      pango
      nss
      gtk3
      at-spi2-atk
      libgbm
      alsa-lib
    ];
    nativeBuildInputs = [
      autoPatchelfHook
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out $out/bin $out/vendor
      mv ./* $out/vendor
      ${
        if platform.isMacOS
        then ''
          ln -s ../vendor/Contents/MacOS/lotion $out/bin/lotion
        ''
        else ''
          ln -s ../vendor/lotion $out/bin/lotion
        ''
      }
      runHook postInstall
    '';

    meta = {
      description = "Unofficial Notion.so app for Linux";
      homepage = "https://github.com/puneetsl/lotion";
      mainProgram = "lotion";
    };
  })
