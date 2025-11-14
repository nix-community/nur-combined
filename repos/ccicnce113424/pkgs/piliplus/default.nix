{
  sources,
  version,
  pubspecLock,
  gitHashes,
  lib,
  flutter335,
  makeDesktopItem,
  copyDesktopItems,
  gitMinimal,
  autoPatchelfHook,
  alsa-lib,
  mpv-unwrapped,
  libplacebo,
  libappindicator,
}:

let
  description = "Third-party Bilibili client developed in Flutter";
in
flutter335.buildFlutterApplication {
  inherit (sources) pname src;
  inherit version pubspecLock gitHashes;

  patches = [ ./disable-auto-update.patch ];

  nativeBuildInputs = [
    copyDesktopItems
    gitMinimal
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    mpv-unwrapped
    libplacebo
    libappindicator
  ];

  # See lib/scripts/build.sh.
  preBuild = ''
    cat <<EOL > lib/build_config.dart
    class BuildConfig {
      static const int versionCode = ${lib.trim (builtins.readFile ./rev-count.txt)};
      static const String versionName = '${version}';
      static const int buildTime = $(git log -1 --format=%ct);
      static const String commitHash = '$(git rev-parse HEAD)';
    }
    EOL
  '';

  postInstall = ''
    # for removing /nix/_temp/... rpaths introduced by flutter build
    # https://github.com/NixOS/nixpkgs/blob/c5ae371f1a6a7fd27823bc500d9390b38c05fa55/pkgs/development/compilers/flutter/build-support/build-flutter-application.nix#L184
    for f in $(find $out/app/$pname -executable -type f); do
      if patchelf --print-rpath "$f" | grep /nix/_temp; then # this ignores static libs (e,g. libapp.so) also
        echo "strip RPath of $f"
        newrp=$(patchelf --print-rpath $f | sed -r "s|/nix/_temp.*ephemeral:||g" | sed -r "s|/nix/_temp.*profile:||g")
        patchelf --set-rpath "$newrp" "$f"
      fi
    done

    # install icons
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
      exec = "piliplus";
      icon = "piliplus";
      desktopName = "PiliPlus";
      categories = [
        "Video"
        "AudioVideo"
      ];
      comment = description;
      extraConfig = {
        "Comment[zh_CN]" = "使用 Flutter 开发的 BiliBili 第三方客户端";
        "Comment[zh_TW]" = "使用 Flutter 開發的 BiliBili 第三方客戶端";
      };
    })
  ];

  passthru.updateScript = ./update.rb;

  meta = {
    inherit description;
    homepage = "https://github.com/bggRGjQaUbCoE/PiliPlus";
    changelog = "https://github.com/bggRGjQaUbCoE/PiliPlus/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.linux;
    mainProgram = "piliplus";
  };
}
