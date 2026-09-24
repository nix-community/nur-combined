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
  mpv-unwrapped,
  webkitgtk_4_1,
  yq-go,
}:

let
  version = "2.3.6";

  src = fetchFromGitHub {
    owner = "Predidit";
    repo = "Kazumi";
    tag = version;
    hash = "sha256-63GJ5ORld5OLlBYBULfsD1SuMBiuEv6h4Z2yGafHJn8=";
  };

  echDeps = lib.importJSON ./ech-http-deps.json;

  echTarget =
    {
      x86_64-linux = "linux-x64";
      aarch64-linux = "linux-arm64";
    }
    .${stdenv.hostPlatform.system}
      or (throw "kazumi: unsupported platform ${stdenv.hostPlatform.system}");

  echDepsSdk = fetchurl {
    inherit (echDeps.${echTarget}) url hash;
  };
in
flutter.buildFlutterApplication {
  pname = "kazumi";
  inherit version src;

  pubspecLock = lib.importJSON ./pubspec.lock.json;
  gitHashes = lib.importJSON ./gitHashes.json;

  nativeBuildInputs = [
    autoPatchelfHook
    yq-go
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

  postPatch = ''
    # Disable the Bangumi proxy by default.
    substituteInPlace lib/services/storage/settings_keys.dart \
      --replace-fail $'_SettingBoxKey.enableBangumiProxy,\n    true,' $'_SettingBoxKey.enableBangumiProxy,\n    false,'
  '';

  preBuild = ''
    # Configure media_kit to link system libraries, and configure ech_http to use the local cache.
    yq --inplace \
      '.hooks.user_defines = {
        "media_kit": { "source": "system" },
        "ech_http": { "binary_cache": ".dart_tool/ech_http_cache" }
      }' \
      pubspec.yaml

    # Retrieve the cache filename hash from ech_http's package metadata to stay in sync with upstream.
    echRoot="$(jq --raw-output '.packages[] | select(.name == "ech_http") | .rootUri | sub("file://"; "")' .dart_tool/package_config.json)"
    echDigest="$(jq --raw-output '.targets["${echTarget}"].sha256' "$echRoot/lib/src/build_support/dependencies.json")"
    mkdir -p .dart_tool/ech_http_cache
    cp "${echDepsSdk}" ".dart_tool/ech_http_cache/${echTarget}-''${echDigest}.zip"
  '';

  postInstall = ''
    install -Dm 0644 assets/linux/io.github.Predidit.Kazumi.desktop -t $out/share/applications/
    install -Dm 0644 assets/images/logo/logo_linux.png $out/share/icons/hicolor/512x512/apps/io.github.Predidit.Kazumi.png
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      # Ensure HTTPS certificate bundle is available to fix TLS verification
      --set SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt"
      --prefix LD_LIBRARY_PATH : "${mpv-unwrapped}/lib:$out/app/$pname/lib"
    )
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
