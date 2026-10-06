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
  branch = "main";
  rev = "1c3cc07aaf6c612547341a63ca19d584eb8497b4";
  hash = "sha256-MDRpvRVxFrATiNKKxXCd3fan8bnYukmMvS+gt1q1osQ=";
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [
    curl
  ];
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
