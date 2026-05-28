{
  stdenvNoCC,
  fetchurl,
  peazip,
  _7zz,
  lib,
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "peazip";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "File and archive manager";
      longDescription = ''
        Free Zip / Unzip software and Rar file extractor. File and archive manager.

        Features volume spanning, compression, authenticated encryption.

        Supports 7Z, 7-Zip sfx, ACE, ARJ, Brotli, BZ2, CAB, CHM, CPIO, DEB, GZ, ISO, JAR, LHA/LZH, NSIS, OOo, PEA, RAR, RPM, split, TAR, Z, ZIP, ZIPX, Zstandard.
      '';
      homepage = "https://peazip.github.io";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.gpl3Only;
    };
  })
else peazip
