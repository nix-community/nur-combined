{
  lib,
  stdenv,
  flutter,
  fetchFromGitHub,
  fetchurl,
  autoPatchelfHook,
  alsa-lib,
  cacert,
  glib-networking,
  gst_all_1,
  libayatana-appindicator,
  mimalloc,
  mpv-unwrapped,
  webkitgtk_4_1,
  yq,
}:

let
  version = "2.3.6";

  src = fetchFromGitHub {
    owner = "Predidit";
    repo = "Kazumi";
    tag = version;
    hash = "sha256-63GJ5ORld5OLlBYBULfsD1SuMBiuEv6h4Z2yGafHJn8=";
  };

  # linux-x64 or linux-arm64 prebuilt SDK target
  echTarget = if stdenv.hostPlatform.isx86_64 then "linux-x64" else "linux-arm64";

  echDepsUrl = "https://github.com/Predidit/libechhttp-linux-build/releases/download/v0.1.0/libechhttp-deps-v0.1.0-${echTarget}.zip";
  echDeps = fetchurl {
    url = echDepsUrl;
    hash = "sha256-+/Ne+vCO9fYkB3f+aV3kaFxLxohjkFLnlYS+0kQxKcQ=";
  };

in
flutter.buildFlutterApplication {
  pname = "kazumi";
  inherit version src;

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  gitHashes = lib.importJSON ./gitHashes.json;

  flutterBuildFlags = [
    "--dart-define=appBuildName=${version}"
    "--dart-define=source=system"
  ];

  customSourceBuilders = {
    # unofficial media_kit_libs_linux
    media_kit_libs_linux =
      { version, src, ... }:
      stdenv.mkDerivation rec {
        pname = "media_kit_libs_linux";
        inherit version src;
        inherit (src) passthru;

        postPatch = ''
          sed -i '/set(MIMALLOC "mimalloc-/,/add_custom_target/d' libs/linux/media_kit_libs_linux/linux/CMakeLists.txt
          sed -i '/set(PLUGIN_NAME "media_kit_libs_linux_plugin")/i add_custom_target("MIMALLOC_TARGET" ALL DEPENDS ${mimalloc}/lib/mimalloc.o)' libs/linux/media_kit_libs_linux/linux/CMakeLists.txt
        '';

        installPhase = ''
          runHook preInstall
          cp -r . "$out"
          runHook postInstall
        '';
      };
    # unofficial media_kit_video
    media_kit_video =
      { version, src, ... }:
      stdenv.mkDerivation rec {
        pname = "media_kit_video";
        inherit version src;
        inherit (src) passthru;

        postPatch = ''
            sed -i '/if(ARCH_NAME STREQUAL "x86_64")/,/if(MEDIA_KIT_LIBS_AVAILABLE)/{ /if(MEDIA_KIT_LIBS_AVAILABLE)/!d; /set(LIBMPV_ZIP_URL/d }' media_kit_video/linux/CMakeLists.txt

            sed -i '/if(MEDIA_KIT_LIBS_AVAILABLE)/i \
          set(LIBMPV_UNZIP_DIR "${mpv-unwrapped}/lib")\n\
          set(LIBMPV_PATH "${mpv-unwrapped}/lib")\n\
          set(LIBMPV_HEADER_UNZIP_DIR "${mpv-unwrapped.dev}/include/mpv")' media_kit_video/linux/CMakeLists.txt
        '';

        installPhase = ''
          runHook preInstall

          cp -r . "$out"

          runHook postInstall
        '';
      };
  };

  postPatch = ''
    # Set hooks.user_defines so media_kit uses the system library and
    # ech_http looks up its prebuilt SDK in .dart_tool/ech_http_cache
    yq -Y '.hooks = {"user_defines": {"media_kit": {"source": "system"}, "ech_http": {"binary_cache": ".dart_tool/ech_http_cache"}}}' pubspec.yaml > pubspec.yaml.new && mv pubspec.yaml.new pubspec.yaml

    # Fix Flutter 3.24+ API change
    substituteInPlace lib/pages/plugin_editor/plugin_view_page.dart \
      --replace-fail "onReorderItem:" "onReorder:"

    # Disable Bangumi proxy by default
    sed -i 's/enableBangumiProxy,\s*true,/enableBangumiProxy,\n    false,/' lib/services/storage/settings_keys.dart

    # Fix upstream bug: appBuildName is a --dart-define var, not from flutter/services.dart
    sed -i "/import 'package:flutter\/services.dart' show appBuildName;/d" lib/request/config/api_endpoints.dart
    sed -i "s/appBuildName ?? '0.0.0'/const String.fromEnvironment('appBuildName', defaultValue: '${version}')/" lib/request/config/api_endpoints.dart
  '';

  # Dynamically read SDK sha256 from ech_http's manifest; copy pre-fetched zip into
  # the hook cache so the build runs fully offline.
  preBuild = ''
    echRoot="$(jq -r '.packages[] | select(.name == "ech_http") .rootUri | sub("file://"; "")' .dart_tool/package_config.json)"
    echDepsSha256="$(yq -r '.targets["${echTarget}"].sha256' "$echRoot/lib/src/build_support/dependencies.json")"
    mkdir -p .dart_tool/ech_http_cache
    cp "${echDeps}" ".dart_tool/ech_http_cache/${echTarget}-''${echDepsSha256}.zip"
  '';

  # Ensure HTTPS certificate bundle is available to fix TLS verification
  preFixup = ''
    gappsWrapperArgs+=(
      --set SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt"
    )
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    yq
  ];

  buildInputs = [
    alsa-lib
    cacert
    glib-networking
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gstreamer
    libayatana-appindicator
    mpv-unwrapped
    webkitgtk_4_1
  ];

  postInstall = ''
    install -Dm 0644 assets/linux/io.github.Predidit.Kazumi.desktop -t $out/share/applications/
    install -Dm 0644 assets/images/logo/logo_linux.png $out/share/icons/hicolor/512x512/apps/io.github.Predidit.Kazumi.png
  '';

  passthru.updateScript = ./update.py;

  meta = {
    description = "Watch Animes online with danmaku support";
    homepage = "https://github.com/Predidit/Kazumi";
    mainProgram = "kazumi";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.lonerOrz ];
    platforms = lib.platforms.linux;
  };
}
