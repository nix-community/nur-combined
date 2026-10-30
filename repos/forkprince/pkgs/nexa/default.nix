{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "nexa";
  inherit (ver) version;

  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "End-to-end encrypted chat, calls and servers";
    homepage = "https://nexa.fish";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = pname;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [unzip];

      extraInstall = ''
        mkdir -p $out/bin
        ln -s "$out/Applications/Nexa.app/Contents/MacOS/Nexa" "$out/bin/${pname}"
      '';
    })
  else
    lib.helper.mkAppImage {
      inherit pname version src meta;

      desktopName = "Nexa";
      categories = [
        "Network"
        "Chat"
        "InstantMessaging"
      ];
      startupWMClass = "nexa";
    }
