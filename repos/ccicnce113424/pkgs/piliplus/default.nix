{
  sources,
  version,
  srcInfo,
  pubspecLock,
  gitHashes,
  lib,
  flutter347,
  gitMinimal,
  powershell,
  makeDesktopItem,
  copyDesktopItems,
  makeWrapper,
  pkg-config,
  alsa-lib,
  mpv-unwrapped,
  libplacebo,
  libappindicator,
  webkitgtk_4_1,
  gtk3,
  libx11,
  libxi,
}:
let
  description = "Third-party Bilibili client developed in Flutter";
  # majorMinorPatch = v: builtins.concatStringsSep "." (lib.take 3 (builtins.splitVersion v));
  flutter = flutter347;
in
flutter.buildFlutterApplication {
  inherit (sources) pname src;
  inherit version pubspecLock gitHashes;

  passthru.updateScript = [ ./update.sh ];

  patches = [
    ./disable-auto-update.patch
    ./no-remove-before-patch.patch
  ];

  nativeBuildInputs = [
    gitMinimal # used extensively in lib/scripts/patch.ps1
    powershell
    copyDesktopItems
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    mpv-unwrapped
    libplacebo
    libappindicator
    webkitgtk_4_1
    gtk3
    libx11
    libxi
  ];

  preBuild = ''
    # package:hooks runs native-asset build hooks (cnativeapi) in a stripped
    # environment where only PATH, HOME, TMP*, NIX_* ... survive, so
    # PKG_CONFIG_PATH is lost and its `pkg-config --cflags gtk+-3.0 x11 xi`
    # cannot find the .pc files. Wrap pkg-config to restore the search path
    # when it is missing; the hook resolves it through PATH, which is passed
    # through. When PKG_CONFIG_PATH is already set (e.g. the Linux CMake
    # build), stay out of the way so the pkg-config wrapper's own role-based
    # search path keeps working.
    hookPkgConfigPath="''${PKG_CONFIG_PATH:-}"
    for v in "''${PKG_CONFIG_PATH_FOR_BUILD:-}" "''${PKG_CONFIG_PATH_FOR_TARGET:-}"; do
      [ -z "$v" ] || hookPkgConfigPath="$hookPkgConfigPath:$v"
    done
    mkdir -p .pkg-config-wrapper
    cat > .pkg-config-wrapper/pkg-config <<EOF
    #!$(command -v sh)
    if [ -z "\$PKG_CONFIG_PATH" ]; then
      export PKG_CONFIG_PATH="$hookPkgConfigPath"
    fi
    exec "${pkg-config}/bin/pkg-config" "\$@"
    EOF
    chmod +x .pkg-config-wrapper/pkg-config
    export PATH="$PWD/.pkg-config-wrapper:$PATH"

    # see lib/scripts/build.ps1
    cat <<JSON > pili_release.json
    {
      "pili.hash": "${srcInfo.rev}",
      "pili.name": "${version}",
      "pili.code": ${toString srcInfo.revCount},
      "pili.time": ${toString srcInfo.time}
    }
    JSON

    export FLUTTER_ROOT="$PWD/.flutter-sdk"
    cp -aL '${flutter.sdk}' "$FLUTTER_ROOT"
    chmod -R u+w "$FLUTTER_ROOT"
    git -C "$FLUTTER_ROOT" reset --hard HEAD

    export PUB_CACHE="$PWD/.pub-cache"
    mkdir -p "$PUB_CACHE/hosted/pub.dev"

    # build a writable pub cache with the packages that patch.ps1 patches
    buildWritablePubCache() {
      packageDir="$(jq --arg packageName "$1" -r '
        .packages[]
        | select(.name == $packageName)
        | .rootUri
        | ltrimstr("file://")
        | rtrimstr("/.")
      ' .dart_tool/package_config.json)"
      cacheDir="$PUB_CACHE/hosted/pub.dev/$(basename "$packageDir" | sed 's/^[^-]*-pub-//')"
      cp -a "$packageDir" "$cacheDir"
      chmod -R u+w "$cacheDir"
      echo "$cacheDir"
    }
    materialUiCacheDir="$(buildWritablePubCache material_ui)"
    buildWritablePubCache cupertino_ui > /dev/null

    HOME="$PWD" GITHUB_WORKSPACE="$PWD" pwsh lib/scripts/patch.ps1 Linux

    # point package resolution at the patched Flutter SDK and material_ui.
    jq --arg flutterRoot "file://$FLUTTER_ROOT" --arg materialRoot "file://$materialUiCacheDir/." '
      .packages |= map(
        if (.rootUri | contains("flutter-sdk-")) then
          if .name == "sky_engine" then .rootUri = "\($flutterRoot)/bin/cache/pkg/sky_engine/."
          else .rootUri = "\($flutterRoot)/packages/\(.name)/."
          end
        elif .name == "material_ui" then .rootUri = $materialRoot
        else .
        end
      )
    ' .dart_tool/package_config.json > .dart_tool/package_config.json.tmp
    mv .dart_tool/package_config.json.tmp .dart_tool/package_config.json
  '';

  flutterBuildFlags = [ "--dart-define-from-file=pili_release.json" ];

  postFixup = ''
    # cnativeapi's @Native bindings dlopen libcnativeapi.so by bare name;
    # DynamicLibrary.open() is called from libflutter_linux_gtk.so and ignores
    # the executable RUNPATH, so put the bundle's lib/ dir on LD_LIBRARY_PATH.
    wrapProgram $out/bin/piliplus \
      --prefix LD_LIBRARY_PATH : "$out/app/piliplus/lib"
  '';

  postInstall = ''
    declare -A sizes=(
      [mdpi]=128
      [hdpi]=192
      [xhdpi]=256
      [xxhdpi]=384
      [xxxhdpi]=512
    )
    for var in "''${!sizes[@]}"; do
      width=''${sizes[$var]}
      install -Dm644 "android/app/src/main/res/drawable-$var/splash.png" \
        "$out/share/icons/hicolor/''${width}x$width/apps/piliplus.png"
    done
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "piliplus";
      desktopName = "PiliPlus";
      comment = description;
      extraConfig = {
        "Comment[zh_CN]" = "使用 Flutter 开发的 BiliBili 第三方客户端";
        "Comment[zh_TW]" = "使用 Flutter 開發的 BiliBili 第三方客戶端";
      };
      exec = "piliplus";
      icon = "piliplus";
      terminal = false;
      startupWMClass = "com.example.piliplus";
      categories = [
        "Video"
        "AudioVideo"
        "Player"
      ];
    })
  ];

  meta = {
    inherit description;
    homepage = "https://github.com/bggRGjQaUbCoE/PiliPlus";
    changelog = "https://github.com/bggRGjQaUbCoE/PiliPlus/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      ulysseszhan
      ccicnce113424
    ];
    platforms = lib.platforms.linux;
    mainProgram = "piliplus";
  };
}
