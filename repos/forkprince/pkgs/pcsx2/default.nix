# NOTE: MacOS version is untested
{
  stdenvNoCC,
  pcsx2-bin,
  fetchurl,
  pcsx2,
  lib,
  ...
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  pcsx2-bin.overrideAttrs (old: {
    src = fetchurl (lib.helper.getSingle ver);
    inherit (ver) version;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      app=$(find . -maxdepth 2 -name "*.app" -type d | head -n1)
      cp -R "$app" $out/Applications/
      runHook postInstall
    '';

    meta.platforms = lib.platforms.darwin;
  })
else pcsx2
