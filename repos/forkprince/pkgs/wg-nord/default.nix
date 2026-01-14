# NOTE: Untested on MacOS
{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
  ...
}: let
  ver = lib.helper.read ./version.json;
  platform = stdenvNoCC.hostPlatform.system;

  src = fetchurl (lib.helper.getPlatform platform ver);
  inherit (ver) version;
in
  stdenvNoCC.mkDerivation {
    pname = "wg-nord";

    inherit version src;

    nativeBuildInputs = [unzip];

    sourceRoot = ".";

    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 wg-nord $out/bin/wg-nord
      runHook postInstall
    '';

    meta = {
      description = "WireGuard configuration generator for NordVPN";
      homepage = "https://github.com/n-thumann/wg-nord";
      license = lib.licenses.mit;
      maintainers = ["Prinky"];
      platforms = lib.platforms.unix;
      mainProgram = "wg-nord";
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
