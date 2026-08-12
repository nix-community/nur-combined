{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "finetune";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Per-application volume mixer, equalizer, and audio router";
      homepage = "https://github.com/ronitsingh10/FineTune";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.gpl3;
    };
  })
