{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "steamac";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Valve's official ARM64 SteamOS in a lightweight VM on Apple Silicon";
      homepage = "https://github.com/fxgl/steamac";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.asl20;
      platforms = ["aarch64-darwin"];
    };
  })
