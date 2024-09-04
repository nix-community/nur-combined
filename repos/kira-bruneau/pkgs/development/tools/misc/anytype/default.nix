{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  anytype-heart,
  anytype-nmh,
  copyDesktopItems,
  jq,
  makeWrapper,
  pkg-config,
  libsecret,
  electron,
  libGL,
  makeDesktopItem,
  nix-update-script,
}:

let
  l10n-anytype-ts = fetchFromGitHub {
    owner = "anyproto";
    repo = "l10n-anytype-ts";
    rev = "b2be402bb1939aec57b5f4f18c2abc0596df7e87";
    hash = "sha256-rjkXkB1auOMesjjX0gUSUJU+dqkZdI9zRYODJTARhtQ=";
  };
in
buildNpmPackage rec {
  pname = "anytype";
  version = "0.42.6";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "anytype-ts";
    rev = "refs/tags/v${version}";
    hash = "sha256-BkNQCREVu39DvmGknWW2omWlix2DMmOdWnLMi5hYzCE=";
  };

  patches = [
    # Workaround for electron 28+
    ./fix-path-for-asar-unpack.patch
  ];

  npmDepsHash = "sha256-Ybfy8qctUTfDJARx6zFJyFEzyPNHLcxjLWQleOKfiBQ=";

  # middleware: https://github.com/anyproto/anytype-ts/blob/v0.42.6/update-ci.sh
  # langs: https://github.com/anyproto/anytype-ts/blob/v0.42.6/electron/hook/locale.js
  postUnpack = ''
    if [ $(cat "$sourceRoot/middleware.version") != ${lib.escapeShellArg anytype-heart.version} ]; then
      echo 'ERROR: middleware version mismatch'
      exit 1
    fi

    ln -s ${anytype-heart}/bin/* "$sourceRoot/dist"
    ln -s ${anytype-heart}/include/anytype/protobuf/* "$sourceRoot/dist/lib"
    ln -s ${anytype-heart}/share/anytype/json/* "$sourceRoot/dist/lib/json/generated"
    ln -s ${anytype-nmh}/bin/* "$sourceRoot/dist"

    while IFS= read -r lang; do
      ln -s "${l10n-anytype-ts}/locales/$lang.json" "$sourceRoot/dist/lib/json/lang"
    done < <(jq -r '.enabledLangs | .[]'  "$sourceRoot/electron/json/constant.json")
  '';

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
    ELECTRON_SKIP_SENTRY = 1;
    SENTRYCLI_SKIP_DOWNLOAD = 1;
  };

  nativeBuildInputs = [
    copyDesktopItems
    jq
    makeWrapper
    pkg-config
  ];

  buildInputs = [ libsecret ];

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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      ''^v(\d+\.\d+\.\d+)$''
    ];
  };

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
