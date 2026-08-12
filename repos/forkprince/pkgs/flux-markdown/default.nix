{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "flux-markdown";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Markdown Preview Enhanced for macOS QuickLook";
      homepage = "https://github.com/xykong/flux-markdown";
      maintainers = with lib.maintainers; [Prinky];
      license = with lib.licenses; [
        unfree
        gpl3
      ];
    };
  })
