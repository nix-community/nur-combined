{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "clop";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [_7zz];

    unpackPhase = ''
      runHook preUnpack
      7zz x -y -snld20 "$src"
      runHook postUnpack
    '';

    meta = {
      description = "Image, video and clipboard optimiser";
      homepage = "https://lowtechguys.com/clop/";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.gpl3;
    };
  })
