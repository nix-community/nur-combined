{ lib
, buildNpmPackage
, fetchFromGitHub
, anytype-heart
, anytype-nmh
, fetchpatch
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
    rev = "3bd7be346cdaaa78d4549c7d6cdb38b26b48773d";
    hash = "sha256-3EAiAuEhZTGRgfnwbogKrAkPg5LPbe/bU6fNKjdk2bQ=";
  };
in
buildNpmPackage rec {
  pname = "anytype";
  version = "0.39.0";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "anytype-ts";
    rev = "refs/tags/v${version}";
    hash = "sha256-Q6tRBTWWq5gwfVSLhNCjaNrbzs5TkgMG4v/LG8MldJg=";
  };

  npmDepsHash = "sha256-V3J4dGMi8u8LxMh6TNJ46lnQCHO53eGg6CJ/Qd1YyIM=";

  # https://github.com/anyproto/anytype-ts/blob/v0.39.0/electron/js/util.js#L223-L230
  enabledLangs = [
    "cs-CZ" "da-DK" "de-DE"
    "en-US" "es-ES" "fr-FR"
    "hi-IN" "id-ID" "it-IT"
    "lt-LT" "ja-JP" "ko-KR"
    "nl-NL" "no-NO" "pl-PL"
    "pt-BR" "ro-RO" "ru-RU"
    "tr-TR" "uk-UA" "vi-VN"
    "zh-CN" "zh-TW"
  ];

  # middleware: https://github.com/anyproto/anytype-ts/blob/v0.39.0/update-ci.sh
  # langs: https://github.com/anyproto/anytype-ts/blob/v0.39.0/electron/hook/locale.js
  postUnpack = ''
    if [ $(cat "$sourceRoot/middleware.version") != ${lib.escapeShellArg anytype-heart.version} ]; then
      echo 'ERROR: middleware version mismatch'
      exit 1
    fi

    ln -s ${anytype-heart}/bin/* "$sourceRoot/dist"
    ln -s ${anytype-heart}/include/anytype/protobuf/* "$sourceRoot/dist/lib"
    ln -s ${anytype-heart}/share/anytype/json/* "$sourceRoot/dist/lib/json/generated"
    ln -s ${anytype-nmh}/bin/* "$sourceRoot/dist"

    for lang in ''${enabledLangs[@]}; do
      ln -s "${l10n-anytype-ts}/locales/$lang.json" "$sourceRoot/dist/lib/json/lang"
    done
  '';

  patches = [
    # Fix error on startup if ~/.config/google-chrome doesn't exist
    (fetchpatch {
      url = "https://github.com/anyproto/anytype-ts/commit/b41bb539eb82ecb32f5d570b63443086615f8dd7.patch";
      hash = "sha256-XmAFctpjkXCZS+kHPBun0MQhgSwd5kYq7kCZiT+P4X4=";
    })
  ];

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
    mainProgram = "anytype";
  };
}
