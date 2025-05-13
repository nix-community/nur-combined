{
  findutils,
  jq,
  lib,
  makeSetupHook,
  strip-nondeterminism,
  unzip,
  zip,
}:
makeSetupHook {
  name = "wrap-firefox-addons-hook";
  substitutions = {
    find = lib.getExe' findutils "find";
    jq = lib.getExe jq;
    strip_nondeterminism = lib.getExe strip-nondeterminism;
    unzip = lib.getExe unzip;
    zip = lib.getExe zip;
  };
} ./wrap-firefox-addons-hook.sh
