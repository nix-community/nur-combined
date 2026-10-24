{
  lib,
  stdenv,
  callPackage,
  curl,
  pkg-config,
}:

(callPackage ./generic.nix { }) {
  name = "httpfs";
  repo = "duckdb-httpfs";
  rev = "77392a72077a85897db2519fae11e2c0da972b8a";
  hash = "sha256-Ni2stJrRSbTkHs+SjfuumtrhIVO917Q9uh91O2YalPM=";
  duckdbBuildInputs = [
    curl
  ];
  pkgConfigModules = [ "libcurl" ];
  # FindCURL only reports libcurl itself, but libcurl.a also needs its private dependencies
  duckdbNativeBuildInputs = lib.optionals stdenv.hostPlatform.isStatic [
    pkg-config
  ];
  duckdbPostPatch = lib.optionalString stdenv.hostPlatform.isStatic ''
    substituteInPlace extension_external/httpfs/CMakeLists.txt \
      --replace-fail 'find_package(CURL REQUIRED)' 'find_package(CURL REQUIRED)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(LIBCURL REQUIRED libcurl)
    set(CURL_LIBRARIES ''${LIBCURL_STATIC_LDFLAGS})'
  '';
}
