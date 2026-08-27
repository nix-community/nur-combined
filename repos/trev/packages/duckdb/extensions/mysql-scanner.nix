{
  callPackage,
  mariadb-connector-c,
  stdenv,
}:

let
  mariadbLibrary =
    if stdenv.hostPlatform.isDarwin then
      "${mariadb-connector-c}/lib/mariadb/libmariadb.3.dylib"
    else
      "${mariadb-connector-c}/lib/mariadb/libmariadb.so.3";
in
(callPackage ./generic.nix { }) {
  name = "mysql_scanner";
  repo = "duckdb-mysql";
  branch = "v1.5-variegata";
  rev = "8369ae4bbafbe78d012b34bb55a5401169fee73d";
  hash = "sha256-T8nOiyDhA1LrDN85k7vK4vujl0vyZrHBKxx7nfpBdYE=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [
    mariadb-connector-c
    mariadb-connector-c.dev
  ];
  duckdbPostPatch = ''
    substituteInPlace extension_external/mysql_scanner/CMakeLists.txt \
      --replace-fail "find_package(libmariadb REQUIRED)" \
        "set(MYSQL_LIBRARIES ${mariadbLibrary})"

    python3 - <<'PY'
    from pathlib import Path

    path = Path("extension_external/mysql_scanner/CMakeLists.txt")
    text = path.read_text()
    old = (
        "set(MYSQL_INCLUDE_DIR\n"
        "    " + "$" + "{CMAKE_BINARY_DIR}/vcpkg_installed/"
        + "$" + "{VCPKG_TARGET_TRIPLET}/include/mysql)"
    )
    new = "set(MYSQL_INCLUDE_DIR ${mariadb-connector-c.dev}/include/mysql)"
    if old not in text:
        raise SystemExit(f"pattern not found in {path}: {old!r}")
    path.write_text(text.replace(old, new))
    PY
  '';
}
