{ lib
, fetchFromGitHub
, flutter
, runCommand
, rustPlatform
, rustc
, stdenv
, pkg-config
, protobuf
, cmake
, copyDesktopItems
, makeDesktopItem
, autoPatchelfHook
, alsa-lib
, atk
, cairo
, curl
, gdk-pixbuf
, glib
, gtk3
, harfbuzz
, libayatana-appindicator
, libGL
, libnotify
, libsecret
, libxkbcommon
, openssl
, pango
, sqlite
, webkitgtk_4_1
, zstd
,
}:

let
  pname = "astral";
  version = "2.8.7";

  src = fetchFromGitHub {
    owner = "ldoubil";
    repo = "astral";
    tag = "v${version}";
    hash = "sha256-b3QFgm0ZMnsuExabPuCGiTdsn46CD/MO0nSVSt1cbV0=";
  };

  astralLicense = {
    shortName = "CC-BY-NC-ND-4.0";
    spdxId = "CC-BY-NC-ND-4.0";
    fullName = "Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International";
    url = "https://github.com/ldoubil/astral/blob/v${version}/LICENSE";
    free = false;
    redistributable = true;
  };

  runtimeLibraries = [
    alsa-lib
    atk
    cairo
    curl
    gdk-pixbuf
    glib
    gtk3
    harfbuzz
    libayatana-appindicator
    libGL
    libnotify
    libsecret
    libxkbcommon
    openssl
    pango
    sqlite
    stdenv.cc.cc.lib
    webkitgtk_4_1
    zstd
  ];

  patchedSrc = runCommand "${pname}-${version}-patched-source" { } ''
    cp -r ${src} $out
    chmod -R u+w $out

    cat > $out/rust_builder/linux/CMakeLists.txt <<'EOF'
    cmake_minimum_required(VERSION 3.10)

    set(PROJECT_NAME "rust_lib_astral")
    project(''${PROJECT_NAME} LANGUAGES CXX)

    set(rust_lib_astral_bundled_libraries
      "${rust-lib}/lib/librust_lib_astral.so"
      PARENT_SCOPE
    )
    EOF
  '';

  rust-lib = rustPlatform.buildRustPackage {
    pname = "astral-rust-lib";
    inherit version src;

    sourceRoot = "${src.name}/rust";
    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "easytier-2.6.4" = "sha256-AXFusEVs+7WgKGrcefS+c0J4vPL0siCBAXc0C022Uco=";
        "easytier-rpc-build-0.1.0" = "sha256-AXFusEVs+7WgKGrcefS+c0J4vPL0siCBAXc0C022Uco=";
        "http_req-0.13.1" = "sha256-Q6tPOUrXY14K+QFNuK3JGsxWx3VezQH3LgP3rBPeHi0=";
        "kcp-sys-0.1.0" = "sha256-kIYYFOdfS+SzFfCNRUUxeD8+j8Gt8OYDPLK/FTeb1AU=";
        "service-manager-0.8.0" = "sha256-b2eR11kG7txfOC6OmUXa9xGM9RAHy+W85QFaiozYSVI=";
        "smoltcp-0.12.0" = "sha256-sOsBc1CF/5ofpjQ54d114d39SAFijzyz5pb3w55gdmI=";
        "thunk-rs-0.3.5" = "sha256-cFREqmXHacEdam7wC0LgudsUTk1WRZwj2jWwkCbW4kE=";
        "tun-easytier-1.1.1" = "sha256-pYyO2YWw2KXeMwMirQ//oIZvberOV+9nPuZ0mfmJRcQ=";
        "windivert-0.6.0" = "sha256-FPwXG9J9FN2m+9WmQHNidBU6pI5Sl9odMtLldSL0jHY=";
        "windivert-sys-0.10.0" = "sha256-FPwXG9J9FN2m+9WmQHNidBU6pI5Sl9odMtLldSL0jHY=";
      };
    };

    nativeBuildInputs = [
      cmake
      pkg-config
      protobuf
      rustPlatform.bindgenHook
    ];

    buildInputs = [
      curl
      openssl
      zstd
    ];

    doCheck = false;

    installPhase = ''
      runHook preInstall

      install -Dm755 "$(find target -path '*/release/librust_lib_astral.so' -print -quit)" \
        $out/lib/librust_lib_astral.so

      runHook postInstall
    '';

    meta = {
      description = "Rust library for Astral";
      homepage = "https://github.com/ldoubil/astral";
      license = astralLicense;
      platforms = lib.platforms.linux;
    };
  };

  finalPackage = flutter.buildFlutterApplication {
    inherit pname version;
    src = patchedSrc;

    pubspecLock = lib.importJSON ./pubspec.lock.json;

    nativeBuildInputs = [
      autoPatchelfHook
      copyDesktopItems
    ];

    buildInputs = runtimeLibraries;

    postInstall = ''
      install -Dm644 assets/logo.png $out/share/icons/hicolor/512x512/apps/astral.png
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "astral";
        exec = "astral %U";
        icon = "astral";
        desktopName = "Astral";
        comment = "Cross-platform P2P network application based on EasyTier";
        categories = [ "Network" ];
      })
    ];

    meta = {
      description = "Cross-platform P2P network application based on EasyTier, built from source";
      homepage = "https://github.com/ldoubil/astral";
      changelog = "https://github.com/ldoubil/astral/releases/tag/v${version}";
      license = astralLicense;
      mainProgram = "astral";
      broken = lib.hasPrefix "25.11" lib.version && lib.versionOlder rustc.version "1.95.0";
      platforms = lib.platforms.linux;
    };
  };
in
finalPackage
