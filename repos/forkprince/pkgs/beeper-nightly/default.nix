{
  stdenvNoCC,
  fetchurl,
  beeper,
  unzip,
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

      nativeBuildInputs = [unzip];

      postFixup = ''
        # FIXME: These are broken

        # disable auto update
        for f in "$out/Applications/Beeper Nightly.app/Contents/Resources/app/build/main/main-entry-"*.mjs; do
          [ -f "$f" ] || continue
          sed -i 's/auto_update_disabled:[^,}]*/auto_update_disabled:true/g' "$f"
        done

        # prevent updates
        for f in "$out/Applications/Beeper Nightly.app/Contents/Resources/app/build/main/main-entry-"*.mjs; do
          [ -f "$f" ] || continue
          sed -i -E 's/executeDownload\([^)]+\)\{/executeDownload(){return;/g' "$f"
        done

        # hide version status element on about page otherwise a error message is shown
        for f in "$out/Applications/Beeper Nightly.app/Contents/Resources/app/build/renderer/"*.css; do
          [ -f "$f" ] || continue
          sed -i '$ a\.subview-prefs-about > div:nth-child(2) {display: none;}' "$f"
        done
      '';
    })
  else
    beeper.overrideAttrs (old: {
      inherit pname version src meta;
    })
