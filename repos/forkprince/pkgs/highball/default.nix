{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  entitlements = builtins.toFile "highball-entitlements.plist" ''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>com.apple.security.device.audio-input</key><true/>
</dict></plist>
'';
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "highball";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [unzip];

    extraInstall = ''
      app="$out/Applications/Highball.app"

      find "$app" -name '._*' -delete

      plist="$app/Contents/Info.plist"
      sed -i 's|<key>SUEnableAutomaticChecks</key>[[:space:]]*<true/>|<key>SUEnableAutomaticChecks</key><false/>|' "$plist"
      grep -qF '<key>SUEnableAutomaticChecks</key><false/>' "$plist"

      /usr/bin/codesign --force -s - --entitlements ${entitlements} "$app"
      /usr/bin/codesign --verify --strict "$app"
    '';

    meta = {
      description = "Run Windows games on Apple Silicon";
      homepage = "https://gauthierpiarrette.github.io/highball/";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.gpl3;
    };
  })
