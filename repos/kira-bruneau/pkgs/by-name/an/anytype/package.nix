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
  gitUpdater,
}:

let
  l10n-anytype-ts = fetchFromGitHub {
    owner = "anyproto";
    repo = "l10n-anytype-ts";
    rev = "89343848ff6e2bc655afa3c5a1d905fbc47197c5";
    hash = "sha256-Px6orAg7Lf05XXHKTznMwu/AlLsV23i+CdKT0T7r2Iw=";
  };
in
buildNpmPackage rec {
  pname = "anytype";
  version = "0.46.1";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "anytype-ts";
    tag = "v${version}";
    hash = "sha256-S8X8NTj5LCGoWasRbYZ3gdDoi1oi6/Ji/hYH1+q7HMc=";
  };

  patches = [
    # Workaround for electron 28+
    ./fix-path-for-asar-unpack.patch
  ];

  npmDepsHash = "sha256-pmPg/idU3RK9TtaKy2AE/rYYumIUMd/EG01/QPq2aPg=";

  # middleware: https://github.com/anyproto/anytype-ts/blob/v0.46.1/update-ci.sh
  # langs: https://github.com/anyproto/anytype-ts/blob/v0.46.1/electron/hook/locale.js
  postUnpack = ''
    expected_middleware_version="v$(cat "$sourceRoot/middleware.version")"
    actual_middleware_version=${lib.escapeShellArg "v${lib.escapeShellArg anytype-heart.version}"}
    if [ "$expected_middleware_version" != "$actual_middleware_version" ]; then
      echo "error: expected anytype-heart $expected_middleware_version, but got $actual_middleware_version"
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

  # Prefer gitUpdater over nix-update-script, since nix-update can
  # only query the latest 10 releases and often doesn't include a
  # single stable release.
  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
    allowedVersions = "^([0-9]+\\.[0-9]+\\.[0-9]+)$";
  };

  meta = with lib; {
    description = "Official Anytype client";
    homepage = "https://anytype.io";
    changelog = "https://releases.any.org/desktop-${builtins.replaceStrings [ "." ] [ "" ] version}";
    license = licenses.unfree; # Any Source Available License 1.0
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.linux;
    mainProgram = "anytype";
  };
}
