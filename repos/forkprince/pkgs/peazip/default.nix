# NOTE: This is untested on MacOS
{
  stdenvNoCC,
  fetchurl,
  peazip,
  _7zz,
  lib,
  ...
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;

  platform = stdenvNoCC.hostPlatform.system;

  src = fetchurl (lib.helper.getPlatform platform ver);
  inherit (ver) version;
in
  stdenvNoCC.mkDerivation {
    pname = "peazip";

    inherit version src;

    nativeBuildInputs = [_7zz];

    sourceRoot = ".";

    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      app=$(find . -maxdepth 2 -name "*.app" -type d | head -n1)
      cp -R "$app" $out/Applications/
      runHook postInstall
    '';

    meta = {
      description = "File and archive manager";
      longDescription = ''
        Free Zip / Unzip software and Rar file extractor. File and archive manager.

        Features volume spanning, compression, authenticated encryption.

        Supports 7Z, 7-Zip sfx, ACE, ARJ, Brotli, BZ2, CAB, CHM, CPIO, DEB, GZ, ISO, JAR, LHA/LZH, NSIS, OOo, PEA, RAR, RPM, split, TAR, Z, ZIP, ZIPX, Zstandard.
      '';
      homepage = "https://peazip.github.io";
      maintainers = ["Prinky"];
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.darwin;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
else peazip
