# Build logic shared by PiliPlus and its forks. `pilinara` reuses this helper by
# passing its own sources, patches, desktop strings and meta as derivation
# arguments, so the Flutter/patch pipeline lives in exactly one place.
{
  lib,
  flutter347,
  gitMinimal,
  powershell,
  makeDesktopItem,
  copyDesktopItems,
  autoPatchelfHook,
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
  flutter = flutter347;
in
lib.extendMkDerivation {
  constructDrv = flutter.buildFlutterApplication;

  # Read by `extendDrvArgs`; they describe the fork rather than the derivation.
  excludeDrvArgNames = [
    "srcInfo"
    "desktopName"
    "startupWMClass"
    "commentZhCN"
    "commentZhTW"
  ];

  extendDrvArgs =
    finalAttrs:
    args@{
      srcInfo,
      meta,
      desktopName,
      startupWMClass,
      commentZhCN,
      commentZhTW,
      ...
    }:
    {
      nativeBuildInputs = (args.nativeBuildInputs or [ ]) ++ [
        gitMinimal # used extensively in lib/scripts/patch.ps1
        powershell
        copyDesktopItems
        pkg-config
        autoPatchelfHook
      ];

      buildInputs = (args.buildInputs or [ ]) ++ [
        alsa-lib
        mpv-unwrapped
        libplacebo
        libappindicator
        webkitgtk_4_1
        gtk3
        libx11
        libxi
      ];

      preBuild = (args.preBuild or "") + ''
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
          "pili.name": "${finalAttrs.version}",
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

      flutterBuildFlags = [
        "--dart-define-from-file=pili_release.json"
      ]
      ++ (args.flutterBuildFlags or [ ]);

      # cnativeapi's @Native bindings dlopen libcnativeapi.so by bare name from the
      # bundled Dart code, i.e. from libapp.so / libflutter_linux_gtk.so rather than
      # the executable, so the bundle's lib/ directory has to be appended to the
      # RUNPATH of the bundle's ELFs.
      appendRunpaths = [ "${placeholder "out"}/app/${finalAttrs.pname}/lib" ];

      postInstall = (args.postInstall or "") + ''
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
            "$out/share/icons/hicolor/''${width}x$width/apps/${finalAttrs.pname}.png"
        done
      '';

      desktopItems = (args.desktopItems or [ ]) ++ [
        (makeDesktopItem {
          name = finalAttrs.pname;
          inherit desktopName startupWMClass;
          comment = meta.description;
          extraConfig = {
            "Comment[zh_CN]" = commentZhCN;
            "Comment[zh_TW]" = commentZhTW;
          };
          exec = finalAttrs.pname;
          icon = finalAttrs.pname;
          terminal = false;
          categories = [
            "Video"
            "AudioVideo"
            "Player"
          ];
        })
      ];

      meta = meta // {
        changelog = "${meta.homepage}/releases/tag/${finalAttrs.version}";
        license = lib.licenses.gpl3Plus;
        platforms = lib.platforms.linux;
        mainProgram = finalAttrs.pname;
      };
    };
}
