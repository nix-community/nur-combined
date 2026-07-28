{
  lib,
  fetchurl,
  stdenvNoCC,
}:
let
  version = "0.2.13";
  versionParts = lib.splitVersion version;
  versionCode = lib.pipe versionParts [
    (map builtins.toString)
    (a: a ++ [ "0" ])
    (builtins.concatStringsSep "")
    lib.toIntBase10
    builtins.toString
  ];
  file = fetchurl {
    url = "https://f-droid.org/repo/org.fdroid.fdroid.privileged_${versionCode}.apk";
    hash = "sha256-EAhSWhe09qk6xpD5xQ3LZ1tr6/U9KHnbyYumWhyy4o0=";
  };
in
assert (builtins.length versionParts) == 3;
stdenvNoCC.mkDerivation {
  pname = "fdroid-privileged-extension";
  inherit version;

  buildCommand = ''
    mkdir -p $out/apk/release
    ln -s ${file} $out/apk/release/${file.name}
  '';

  passthru = {
    applicationIds = [ "org.fdroid.fdroid.privileged" ];
    inherit file versionCode;
  };
}
# {
#   fetchFromGitLab,
#   buildGradleAndroidPackage,
# }:
# buildGradleAndroidPackage rec {
#   pname = "fdroid-privileged-extension";
#   version = "0.2.13";
#   applicationIds = [ "org.fdroid.fdroid.privileged" ];
#
#   src = fetchFromGitLab {
#     owner = "fdroid";
#     repo = "privileged-extension";
#     tag = version;
#   };
#
#   # lockFile = ./gradle.lock;
# }
