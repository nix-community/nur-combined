{ lib
, buildNpmPackage
, fetchFromGitHub
, anytype-heart
, copyDesktopItems
, makeWrapper
, pkg-config
, libsecret
, electron
, libGL
, makeDesktopItem
, nix-update-script
}:

let
  l10n-anytype-ts = fetchFromGitHub {
    owner = "anyproto";
    repo = "l10n-anytype-ts";
    rev = "b436d330e6bf1d1420556f1f19fafe9a570d2d37";
    hash = "sha256-yEGgyWh2tQXyMd8cye8HcZmuYa3X7P+0qVwsBbrVO+o=";
  };
in
buildNpmPackage rec {
  pname = "anytype";
  version = "0.36.0";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "anytype-ts";
    rev = "refs/tags/v${version}";
    hash = "sha256-M8jT6Okkjvy55VVR8zXBXyaicabX9M/3F9kGlgxVDqE=";
  };

  patches = [
    ./fix-resolved.patch
  ];

  npmDepsHash = "sha256-yaa3uBw+vqiS9h8VkOUP/lH4N/9efny6ZVVM+WJyAyk=";

  # https://github.com/anyproto/anytype-ts/blob/v0.36.0/electron/js/util.js#L214-L224
  enabledLangs = [
    "da-DK" "de-DE" "en-US"
    "es-ES" "fr-FR" "hi-IN"
    "id-ID" "it-IT" "nl-NL"
    "no-NO" "pl-PL" "pt-BR"
    "ro-RO" "ru-RU" "tr-TR"
    "uk-UA" "vi-VN" "zh-CN"
    "zh-TW"
  ];

  # middleware: https://github.com/anyproto/anytype-ts/blob/v0.36.0/update-ci.sh
  # langs: https://github.com/anyproto/anytype-ts/blob/v0.36.0/electron/hook/locale.js
  postUnpack = ''
    if [ $(cat "$sourceRoot/middleware.version") != ${lib.escapeShellArg anytype-heart.version} ]; then
      echo 'ERROR: middleware version mismatch'
      exit 1
    fi

    ln -s ${anytype-heart}/libexec/anytype/grpcserver "$sourceRoot/dist/anytypeHelper"
    ln -s ${anytype-heart}/include/anytype/protobuf/* "$sourceRoot/dist/lib"
    ln -s ${anytype-heart}/share/anytype/json/* "$sourceRoot/dist/lib/json/generated"

    for lang in ''${enabledLangs[@]}; do
      ln -s "${l10n-anytype-ts}/locales/$lang.json" "$sourceRoot/dist/lib/json/lang"
    done
  '';

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
    ELECTRON_SKIP_SENTRY = 1;
    SENTRYCLI_SKIP_DOWNLOAD = 1;
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    libsecret
  ];

  postBuild = ''
    npm exec electron-builder -- \
      --dir \
      -c.electronDist=${electron}/libexec/electron \
      -c.electronVersion=${electron.version}
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/anytype"
    cp -r dist/*-unpacked/{locales,resources{,.pak}} "$out/share/anytype"

    makeWrapper ${electron}/bin/electron "$out/bin/anytype" \
      --add-flags "$out/share/anytype/resources/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL ]} \
      --inherit-argv0

    for size in 16x16 32x32 64x64 128x128 256x256 512x512 1024x1024; do
      mkdir -p "$out/share/icons/hicolor/$size/apps"
      ln -s "$out/share/anytype/resources/app.asar.unpacked/electron/img/icon$size.png" "$out/share/icons/hicolor/$size/apps/anytype.png"
    done

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "anytype";
      desktopName = "Anytype";
      comment = meta.description;
      icon = "anytype";
      exec = "anytype";
      categories = [ "Utility" ];
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Official Anytype client";
    homepage = "https://anytype.io";
    license = licenses.unfree; # Any Source Available License 1.0
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.linux;
  };
}
