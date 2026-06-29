{
  stdenvNoCC,
  fetchurl,
  lib,
  ...
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation {
    pname = "sfw";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    dontUnpack = true;
    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/sfw
      runHook postInstall
    '';

    meta = {
      description = "Wraps your package manager, preventing installation of malicious packages.";
      homepage = "https://github.com/SocketDev/sfw-free";
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [Prinky];
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
      mainProgram = "sfw";
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
