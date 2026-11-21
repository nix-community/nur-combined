{
  stdenvNoCC,
  fetchurl,
  beeper,
  unzip,
  asar,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "beeper-nightly";

  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  inherit (ver) version;

  meta = {
    description = "Universal chat app";
    longDescription = ''
      Beeper is a universal chat app. With Beeper, you can send
      and receive messages to friends, family and colleagues on
      many different chat networks.
    '';
    homepage = "https://beeper.com";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [
      jshcmpbll
      edmundmiller
      zh4ngx
      Prinky
    ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [unzip asar];

      postFixup = ''
        asarDir="$out/Applications/Beeper Nightly.app/Contents/Resources"
        appRoot="$asarDir/app"
        frameworksDir="$out/Applications/Beeper Nightly.app/Contents/Frameworks"

        # asar expects NodeAPI.framework under build/_darwin-arm64/ but zip puts it in Frameworks/
        if [ -d "$frameworksDir/NodeAPI.framework" ] && [ ! -e "$asarDir/app.asar.unpacked/build/_darwin-arm64/NodeAPI.framework" ]; then
          mkdir -p "$asarDir/app.asar.unpacked/build/_darwin-arm64"
          ln -s "$frameworksDir/NodeAPI.framework" "$asarDir/app.asar.unpacked/build/_darwin-arm64/NodeAPI.framework"
        fi

        ${lib.getExe asar} extract "$asarDir/app.asar" "$appRoot"
        rm "$asarDir/app.asar"

        # disable auto update
        for f in "$appRoot"/build/main/main-entry-*.mjs; do
          [ -f "$f" ] || continue
          sed -i -E 's/[A-Za-z_$][A-Za-z0-9_$]*\.conf\.auto_update_disabled\?\?[^;}]*/!0/g' "$f"
        done

        # prevent updates
        for f in "$appRoot"/build/main/main-entry-*.mjs; do
          [ -f "$f" ] || continue
          sed -i -E 's/executeDownload\([^)]+\)\{/executeDownload(){return;/g' "$f"
        done

        # hide version status element on about page otherwise a error message is shown
        for f in "$appRoot"/build/renderer/*.css "$appRoot"/build-browser/*.css; do
          [ -f "$f" ] || continue
          sed -i '$ a\.subview-prefs-about > div:nth-child(2) {display: none;}' "$f"
        done
      '';
    })
  else
    beeper.overrideAttrs (_: {
      inherit pname version src meta;
    })
