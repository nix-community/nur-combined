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
    platforms = lib.platforms.unix;
  };
in
  if stdenvNoCC.isDarwin
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
        sed -i 's/c=d??{},p=c.hw_acceleration??!0/c={...(d??{}),auto_update_disabled:true},p=c.hw_acceleration??!0/g' "$appRoot"/build/main/index-*.mjs

        # prevent updates
        sed -i -E 's/executeDownload\([^)]+\)\{/executeDownload(){return;/g' "$appRoot"/build/main/main-entry-*.mjs

        # hide version status element on about page otherwise a error message is shown
        sed -i '$ a\.subview-prefs-about > div:nth-child(2) {display: none;}' "$appRoot"/build-browser/*.css
      '';
    })
  else
    beeper.overrideAttrs (old: {
      inherit pname version src meta;
    })
