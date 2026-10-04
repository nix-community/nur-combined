{
  lib,
  fetchFromGitHub,
  flutter347,
  libayatana-appindicator,
  buildGoModule,
  rustPlatform,
  makeDesktopItem,
  copyDesktopItems,
  autoPatchelfHook,
  imagemagick,
  sqlite,
}:

let
  pname = "flclash";
  version = "0.8.99";

  src = fetchFromGitHub {
    owner = "chen08209";
    repo = "FlClash";
    tag = "v${version}";
    preFetch = ''
      export GIT_CONFIG_COUNT=1
      export GIT_CONFIG_KEY_0=url.https://github.com/.insteadOf
      export GIT_CONFIG_VALUE_0=git@github.com:
    '';
    hash = "sha256-tjjIO4MLnDHiu9ff4lJgiK87J1kOquIkpYasajLo3C0=";
    fetchSubmodules = true;
  };

  meta = {
    description = "Proxy client based on ClashMeta, simple and easy to use";
    homepage = "https://github.com/chen08209/FlClash";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ VZstless ];
  };

  core = buildGoModule {
    pname = "core";
    inherit version src meta;

    modRoot = "core";

    vendorHash = "sha256-1GWh1ftgF4XSj4s5f6nijAEhGWN+IZKo8gJDH0PbjLw=";

    env.CGO_ENABLED = 0;

    buildPhase = ''
      runHook preBuild

      mkdir --parents $out/bin
      go build -ldflags="-w -s" -tags=with_gvisor -o $out/bin/FlClashCore

      runHook postBuild
    '';
  };

  rustApi = rustPlatform.buildRustPackage {
    pname = "rustApi";
    inherit version src meta;

    sourceRoot = "${src.name}/plugins/rust_api/rust";

    cargoHash = "sha256-59cjtvAvo62VksthtV+ej0mDPhVmCHev0hvyNddIMO8=";

    installPhase = ''
      runHook preInstall

      mkdir --parents $out/lib
      cp target/*/release/librust_api.so $out/lib/

      runHook postInstall
    '';
  };

  # The Helper verifies the digest of the Core binary it is allowed to launch
  # against the value embedded at compile time via `env!("CORE_SHA256")`, which
  # must match the manifest.json shipped next to it.
  helper = rustPlatform.buildRustPackage {
    pname = "helper";
    inherit version src meta;

    sourceRoot = "${src.name}/services/helper";

    cargoHash = "sha256-G2c59JGaO/pLBKRCIUT1F5EE6pmSlUoNEMFaeFVdgzk=";

    preBuild = ''
      export CORE_SHA256="$(sha256sum ${core}/bin/FlClashCore | cut --delimiter=' ' --fields=1)"
      export CORE_NAME=FlClashCore
    '';

    installPhase = ''
      runHook preInstall

      mkdir --parents $out/bin
      install -m555 target/*/release/helper $out/bin/FlClashHelperService

      runHook postInstall
    '';
  };
in
flutter347.buildFlutterApplication {
  inherit pname version src;

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  gitHashes = lib.importJSON ./git-hashes.json;

  # Neutralize nixpkgs' stale built-in source builders for these packages:
  # the "+eol" stubs no longer ship the files they patch, and package:sqlite3
  # is pointed at the system library via the `source: system` user define
  # (see postPatch) instead of a patch of its hook sources.
  customSourceBuilders = {
    sqlite3 = { src, ... }: src;
    sqlite3_flutter_libs = { src, ... }: src;
    sqlcipher_flutter_libs = { src, ... }: src;
  };

  # sqlite3 is resolved with a system lookup (see postPatch), which is
  # performed with dlopen() at runtime and therefore needs to be on
  # LD_LIBRARY_PATH.
  runtimeDependencies = [ sqlite ];

  nativeBuildInputs = [
    copyDesktopItems
    autoPatchelfHook
    imagemagick
  ];

  buildInputs = [ libayatana-appindicator ];

  flutterBuildFlags = [ "--dart-define=APP_ENV=stable" ];

  postPatch = ''
    # The Core, the Helper service and the Rust API library are built
    # separately and staged into the bundle in preBuild/postInstall, so tell
    # the build hooks not to run `go` and `cargo` during `flutter build`.
    # Use the system SQLite instead of downloading a prebuilt library.
    sed --in-place '/^  user_defines:$/a\    sqlite3:\n      source: system' pubspec.yaml
    substituteInPlace pubspec.yaml \
      --replace-fail "build_assets: true" "build_assets: false"

    # Dart 3.13.0 as bundled with flutter347 does not accept the `final`
    # modifier on named parameters (written against Dart >=3.13.2). The
    # modifier only forbids reassigning the parameter inside the function
    # body, so it can be dropped safely.
    sed --in-place --regexp-extended \
      's/^(\s*)final (VoidCallback\? onPressed,)$/\1\2/' \
      lib/views/profiles/overwrite/custom/groups.dart \
      lib/views/profiles/overwrite/custom/rules.dart
  '';

  # RustLib.init() loads librust_api.so with dlopen(), which ignores
  # RUNPATH and only consults LD_LIBRARY_PATH
  extraWrapProgramArgs = "--prefix LD_LIBRARY_PATH : $out/app/flclash/lib";

  desktopItems = [
    (makeDesktopItem {
      name = "flclash";
      exec = "FlClash %U";
      icon = "flclash";
      genericName = "FlClash";
      desktopName = "FlClash";
      categories = [ "Network" ];
      startupWMClass = "com.follow.clash";
      keywords = [
        "FlClash"
        "Clash"
        "ClashMeta"
        "Proxy"
      ];
    })
  ];

  preBuild = ''
    mkdir --parents libclash/linux
    cp ${core}/bin/FlClashCore libclash/linux/FlClashCore
    cp ${helper}/bin/FlClashHelperService libclash/linux/FlClashHelperService
    printf '{"coreSha256":"%s"}\n' \
      "$(sha256sum ${core}/bin/FlClashCore | cut --delimiter=' ' --fields=1)" \
      > libclash/linux/manifest.json
  '';

  postInstall = ''
    cp ${rustApi}/lib/librust_api.so $out/app/$pname/lib/

    # The install phase symlinks every top-level bundle file into $out/bin,
    # but manifest.json is data, not a program to wrap.
    rm $out/bin/manifest.json

    mkdir --parents $out/share/icons/hicolor/512x512/apps
    magick assets/images/icon.png -resize 512x512 $out/share/icons/hicolor/512x512/apps/flclash.png

    # auto-patchelf mangles the CMAKE_INSTALL_RPATH "$ORIGIN/lib" entry into a
    # literal /lib in the final RUNPATH (the $ORIGIN part gets lost). On hosts
    # with libraries in /lib (e.g. Arch Linux) the loader would then pick up
    # the host's GTK instead of the Nix one, breaking startup. Drop it before
    # auto-patchelf runs.
    newRpath=$(patchelf --print-rpath $out/app/$pname/FlClash \
      | sed -E 's#^\$ORIGIN/lib:?##; s#:\$ORIGIN/lib:?#:#g; s#:\$ORIGIN/lib$##')
    patchelf --set-rpath "$newRpath" $out/app/$pname/FlClash
  '';

  passthru = {
    inherit core rustApi helper;
    updateScript = ./update.sh;
    flutter = flutter347;
  };

  meta = meta // {
    mainProgram = "FlClash";
    platforms = lib.platforms.linux;
  };
}
