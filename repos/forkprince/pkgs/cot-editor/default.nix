{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "cot-editor";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Plain-text editor for web pages, program source codes and more";
      homepage = "https://coteditor.com/";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.cc-by-nc-nd-40;
    };
  })
