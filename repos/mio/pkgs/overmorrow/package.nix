{
  lib,
  flutter338,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,
}:

flutter338.buildFlutterApplication rec {
  pname = "overmorrow";
  version = "2.6.2";

  src = fetchFromGitHub {
    owner = "bmaroti9";
    repo = "Overmorrow";
    tag = "v${version}";
    hash = "sha256-QWjUicl9UTnK9wXxl+PzYZ4XUz8eScaC5BZ9/bZNtiI=";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;
  gitHashes = lib.importJSON ./git-hashes.json;

  nativeBuildInputs = [
    copyDesktopItems
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "overmorrow";
      exec = "overmorrow";
      icon = "overmorrow";
      desktopName = "Overmorrow";
      comment = "Weather application";
      categories = [ "Utility" ];
    })
  ];

  postPatch = ''
    # Force Flutter to regenerate plugin registrants with added deps.
    rm -f linux/flutter/generated_plugin_registrant.cc \
      linux/flutter/generated_plugin_registrant.h \
      linux/flutter/generated_plugins.cmake

    # Ensure the Linux geolocator implementation is listed as a dependency.
    if ! grep -q "^  geolocator_linux:" pubspec.yaml; then
      sed -i "/^  geolocator:/a\\  geolocator_linux: ^0.2.3" pubspec.yaml
    fi

    # Provide stub API keys so the build does not fail when the file is missing.
    cat > lib/api_key.dart <<'APIKEYS'
    const String wapi_Key = "REPLACE_ME";
    const String wapi_key = wapi_Key;
    const String access_key = "REPLACE_ME";
    const String timezonedbKey = "REPLACE_ME";
    APIKEYS
  '';

  postInstall = ''
    install -Dm644 assets/icons/icon.png \
      $out/share/icons/hicolor/512x512/apps/overmorrow.png
  '';

  meta = {
    description = "Weather application";
    homepage = "https://github.com/bmaroti9/Overmorrow";
    license = lib.licenses.gpl3Only;
    mainProgram = "overmorrow";
    platforms = lib.platforms.linux;
  };
}
