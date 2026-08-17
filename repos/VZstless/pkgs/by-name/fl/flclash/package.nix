{
  lib,
  fetchFromGitHub,
  flutter344,
  stdenv,
  keybinder3,
  libayatana-appindicator,
  buildGoModule,
  rustPlatform,
  writeText,
  writeScript,
  makeDesktopItem,
  copyDesktopItems,
  autoPatchelfHook,
  imagemagick,
  sqlite,
}:

let
  pname = "flclash";
  version = "0.8.96";

  src = fetchFromGitHub {
    owner = "chen08209";
    repo = "FlClash";
    tag = "v${version}";
    preFetch = ''
      export GIT_CONFIG_COUNT=1
      export GIT_CONFIG_KEY_0=url.https://github.com/.insteadOf
      export GIT_CONFIG_VALUE_0=git@github.com:
    '';
    hash = "sha256-RtBt24GqG6RtIZR+ZXCqTOM4BXHMuE+QRNZ+OJ1U3qY=";
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

    vendorHash = "sha256-7OqFIaxIyhu5bOY5i7hzNO1D6QJxMUc2kNieMuCI4gw=";

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

    cargoHash = "sha256-Os8N7HGQvpm6VQ9ZnVZ6xp0xyZSGP+E2m9hR5tzxYqo=";

    installPhase = ''
      runHook preInstall

      mkdir --parents $out/lib
      cp target/*/release/librust_api.so $out/lib/

      runHook postInstall
    '';
  };
in
flutter344.buildFlutterApplication {
  inherit pname version src;

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  gitHashes = lib.importJSON ./git-hashes.json;

  nativeBuildInputs = [
    copyDesktopItems
    autoPatchelfHook
    imagemagick
  ];

  buildInputs = [
    keybinder3
    libayatana-appindicator
  ];

  flutterBuildFlags = [ "--dart-define=APP_ENV=stable" ];

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

  customSourceBuilders = {
    setup =
      { version, src, ... }:
      stdenv.mkDerivation {
        pname = "setup";
        inherit version src;
        inherit (src) passthru;

        postPatch =
          let
            cmakeLists = writeText "CMakeLists.txt" ''
              cmake_minimum_required(VERSION 3.10)
              set(PROJECT_NAME "setup")
              project(''${PROJECT_NAME} LANGUAGES CXX)
              get_filename_component(PROJECT_ROOT "''${CMAKE_SOURCE_DIR}" DIRECTORY)
              install(PROGRAMS "''${PROJECT_ROOT}/libclash/linux/FlClashCore"
                DESTINATION "''${CMAKE_BINARY_DIR}/bundle"
                COMPONENT Runtime
              )
            '';
          in
          ''
            cp ${cmakeLists} plugins/setup/linux/CMakeLists.txt
          '';

        installPhase = ''
          runHook preInstall

          mkdir --parents $out/plugins
          cp --recursive plugins/setup $out/plugins/

          runHook postInstall
        '';
      };

    rust_api =
      { version, src, ... }:
      stdenv.mkDerivation {
        pname = "rust_api";
        inherit version src;
        inherit (src) passthru;

        postPatch =
          let
            fakeCargokitCmake = writeText "FakeCargokit.cmake" ''
              function(apply_cargokit target manifest_dir lib_name any_symbol_name)
                set("''${target}_cargokit_lib" ${rustApi}/lib/librust_api.so PARENT_SCOPE)
              endfunction()
            '';
          in
          ''
            cp ${fakeCargokitCmake} plugins/rust_api/cargokit/cmake/cargokit.cmake
          '';

        installPhase = ''
          runHook preInstall

          mkdir --parents $out/plugins
          cp --recursive plugins/rust_api $out/plugins/

          runHook postInstall
        '';
      };

    sqlite3 =
      { version, src, ... }:
      stdenv.mkDerivation {
        pname = "sqlite3";
        inherit version src;
        inherit (src) passthru;

        setupHook = writeScript "sqlite3-setup-hook" ''
          sqliteFixupHook() {
            # addToSearchPath (rather than runtimeDependencies+=(...)) so an
            # empty runtimeDependencies env (default for flutter apps) does not
            # create an empty element, which auto-patchelf turns into a /lib
            # RUNPATH entry.
            addToSearchPath runtimeDependencies '${lib.getLib sqlite}'
          }

          preFixupHooks+=(sqliteFixupHook)
        '';

        postPatch = ''
          if [[ -f lib/src/hook/compile/description.dart ]]; then
            substituteInPlace lib/src/hook/compile/description.dart \
              --replace-fail "return fromGitHub(LibraryType.sqlite3);" "return LookupSystem('sqlite3');"
          else
            substituteInPlace lib/src/hook/description.dart \
              --replace-fail "return PrecompiledFromGithubAssets(LibraryType.sqlite3);" "return LookupSystem('sqlite3');"
          fi
        '';

        installPhase = ''
          runHook preInstall

          cp --recursive . "$out"

          runHook postInstall
        '';
      };

    sqlite3_flutter_libs =
      { version, src, ... }:
      stdenv.mkDerivation {
        pname = "sqlite3_flutter_libs";
        inherit version src;
        inherit (src) passthru;

        installPhase = ''
          runHook preInstall

          cp --recursive . "$out"

          runHook postInstall
        '';
      };

    sqlcipher_flutter_libs =
      { version, src, ... }:
      stdenv.mkDerivation {
        pname = "sqlcipher_flutter_libs";
        inherit version src;
        inherit (src) passthru;

        installPhase = ''
          runHook preInstall

          cp --recursive . "$out"

          runHook postInstall
        '';
      };
  };

  preBuild = ''
    mkdir --parents libclash/linux
    cp ${core}/bin/FlClashCore libclash/linux/FlClashCore
  '';

  postInstall = ''
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
    inherit core rustApi;
    updateScript = ./update.sh;
  };

  meta = meta // {
    mainProgram = "FlClash";
    platforms = lib.platforms.linux;
  };
}
