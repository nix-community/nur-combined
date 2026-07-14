# From https://github.com/tpwrules/nixos-apple-silicon/issues/145
{ stdenv, widevine-cdm, ... }:

stdenv.mkDerivation {
  name = "widevine-firefox";
  version = widevine-cdm.version;

  buildCommand = ''
    mkdir -p $out/gmp-widevinecdm/system-installed
    ln -s "${widevine-cdm}/share/google/chrome/WidevineCdm/manifest.json" $out/gmp-widevinecdm/system-installed/manifest.json
    ln -s "${widevine-cdm}/share/google/chrome/WidevineCdm/_platform_specific/linux_arm64/libwidevinecdm.so" $out/gmp-widevinecdm/system-installed/libwidevinecdm.so
  '';

  inherit (widevine-cdm) meta;
}
