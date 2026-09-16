{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}:
let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "beswitched";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Native macOS Switch emulation app with cross-core saves and cloud backup";
      homepage = "https://gitlab.com/dubiusfafa/beswitched-releases";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.gpl3Plus;
    };
  })
