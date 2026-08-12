{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "mcpelauncher-swift";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Native SwiftUI launcher for Minecraft Bedrock on macOS";
      homepage = "https://github.com/hugonote/mcpelauncher-swift";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.mit;
    };
  })
