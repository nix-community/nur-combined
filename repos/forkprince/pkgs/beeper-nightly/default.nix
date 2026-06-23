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
        appRoot="$out/Applications/Beeper Nightly.app/Contents/Resources/app"
        ${lib.getExe asar} extract "$out/Applications/Beeper Nightly.app/Contents/Resources/app.asar" "$appRoot"
        rm "$out/Applications/Beeper Nightly.app/Contents/Resources/app.asar"

        # disable auto update
        sed -i 's/c=d??{},p=c.hw_acceleration??!0/c={...(d??{}),auto_update_disabled:true},p=c.hw_acceleration??!0/g' $appRoot/build/main/index-*.mjs

        # prevent updates
        sed -i -E 's/executeDownload\([^)]+\)\{/executeDownload(){return;/g' $appRoot/build/main/main-entry-*.mjs

        # hide version status element on about page otherwise a error message is shown
        sed -i '$ a\.subview-prefs-about > div:nth-child(2) {display: none;}' $appRoot/build-browser/*.css
      '';
    })
  else
    beeper.overrideAttrs (old: {
      inherit pname version src meta;
    })
