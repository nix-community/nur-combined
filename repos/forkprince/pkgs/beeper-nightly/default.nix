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
      dontFixup = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out/Applications
        cp -r "Beeper Nightly.app" $out/Applications/
        runHook postInstall
      '';
    }
  else
    beeper.overrideAttrs (old: {
      inherit pname name version src meta;
    })
