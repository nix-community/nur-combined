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
    rev = "ccef09cf8f160e8bac31ca23ffb83866edd26637";
    hash = "sha256-PNR40qIDE39rxAA38bg9tF+E8bLoGCORRZZqHGgfAa0=";
  };
in
buildNpmPackage rec {
  pname = "anytype";
  version = "0.38.0";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "anytype-ts";
    rev = "refs/tags/v${version}";
    hash = "sha256-Hpy1X8iC3Izgrl+KWl1BsFDkOucQ4CQluim4z3w21Oo=";
  };

  npmDepsHash = "sha256-jEGBrNQ9T+WpDpu8zoQqybpJk+gsiAqJQNmfEPK6OJA=";

  # https://github.com/anyproto/anytype-ts/blob/v0.38.0/electron/js/util.js#L214-L224
  enabledLangs = [
    "da-DK" "de-DE" "en-US"
    "es-ES" "fr-FR" "hi-IN"
    "id-ID" "it-IT" "ja-JP"
    "nl-NL" "no-NO" "pl-PL"
    "pt-BR" "ro-RO" "ru-RU"
    "tr-TR" "uk-UA" "vi-VN"
    "zh-CN" "zh-TW"
  ];

  # middleware: https://github.com/anyproto/anytype-ts/blob/v0.38.0/update-ci.sh
  # langs: https://github.com/anyproto/anytype-ts/blob/v0.38.0/electron/hook/locale.js
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
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    for icon in electron/img/icons/*; do
      filename=$(basename "$icon")
      size="''${filename%.*}"
      extension="''${filename##*.}"
      mkdir -p "$out/share/icons/hicolor/$size/apps"
      cp "$icon" "$out/share/icons/hicolor/$size/apps/anytype.$extension"
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
    changelog = "https://community.anytype.io/c/news-announcements/release-notes";
    license = licenses.unfree; # Any Source Available License 1.0
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.linux;
  };
}
