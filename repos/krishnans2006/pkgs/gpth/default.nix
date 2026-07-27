# Heavily adapted from https://github.com/NixOS/nixpkgs/pull/414078
# With just a few minor changes (not functionality-related)

{
  lib,
  buildDartApplication,
  fetchFromGitHub,
}:

buildDartApplication rec {
  pname = "gpth";
  version = "3.4.3";

  src = fetchFromGitHub {
    owner = "TheLastGimbus";
    repo = "GooglePhotosTakeoutHelper";
    tag = "v${version}";
    hash = "sha256-loLwBuonOJH04ujqv2yZJfGYE1k1LF+0O+jYWPrYUKA=";
  };

  dartEntryPoints = {
    "bin/gpth" = "bin/gpth.dart";
  };

  # Vendored to avoid IFD from autoPubspecLock (breaks NUR CI restrict-eval)
  pubspecLock = lib.importJSON ./pubspec.lock.json;

  meta = {
    description = "Tool to organize the Google Photos Takeout archive into one chronological folder";
    homepage = "https://github.com/TheLastGimbus/GooglePhotosTakeoutHelper";
    changelog = "https://github.com/TheLastGimbus/GooglePhotosTakeoutHelper/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.krishnans2006 ];
    mainProgram = "gpth";
  };
}
