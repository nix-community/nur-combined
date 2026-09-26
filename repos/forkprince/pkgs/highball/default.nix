{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "highball";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [unzip];

    extraInstall = ''
      plist="$out/Applications/Highball.app/Contents/Info.plist"
      sed -i 's|<key>SUEnableAutomaticChecks</key>[[:space:]]*<true/>|<key>SUEnableAutomaticChecks</key><false/>|' "$plist"
      grep -qF '<key>SUEnableAutomaticChecks</key><false/>' "$plist"
    '';

    meta = {
      description = "Run Windows games on Apple Silicon";
      homepage = "https://gauthierpiarrette.github.io/highball/";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.gpl3;
    };
  })
