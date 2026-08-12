{
  pixelflasher,
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "pixelflasher";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Pixel™ phone flashing GUI utility with features";
      homepage = "https://github.com/badabing2005/PixelFlasher";
      changelog = "https://github.com/badabing2005/PixelFlasher/releases/tag/v${ver.version}";
      license = lib.licenses.agpl3Plus;
      maintainers = with lib.maintainers; [Prinky];
    };
  })
else pixelflasher
