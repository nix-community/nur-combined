{
  stdenvNoCC,
  fetchurl,
  beeper,
  unzip,
  lib,
  ...
}: let
  ver = lib.helper.read ./version.json;
  platform = stdenvNoCC.hostPlatform.system;

  pname = "beeper-nightly";
  name = "${pname}-${version}";

  src = fetchurl (lib.helper.getApiPlatform platform ver);

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
      "Prinky"
    ];
    platforms = lib.platforms.unix;
  };
in
  if stdenvNoCC.isDarwin
  then
    stdenvNoCC.mkDerivation {
      inherit pname version src meta;

      nativeBuildInputs = [unzip];

      sourceRoot = ".";

      dontBuild = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out/Applications
        cp -r "Beeper Nightly.app" $out/Applications/
        runHook postInstall
      '';

      postFixup = ''
        # disable auto update
        sed -i 's/[^=]*\.auto_update_disabled/true/' "$out/Applications/Beeper Nightly.app/Contents/Resources/app/build/main/main-entry-"*.mjs

        # prevent updates
        sed -i -E 's/executeDownload\([^)]+\)\{/executeDownload(){return;/g' "$out/Applications/Beeper Nightly.app/Contents/Resources/app/build/main/main-entry-"*.mjs

        # hide version status element on about page otherwise a error message is shown
        sed -i '$ a\.subview-prefs-about > div:nth-child(2) {display: none;}' "$out/Applications/Beeper Nightly.app/Contents/Resources/app/build/renderer/PrefsPanes-"*.css
      '';
    }
  else
    beeper.overrideAttrs (old: {
      inherit pname name version src meta;
    })
