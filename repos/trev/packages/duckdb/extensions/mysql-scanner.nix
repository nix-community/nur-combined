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
  rev = "a04f824de11ee55fe5a95af9ea780112a14c4083";
  hash = "sha256-bMKWV58gUVoFm89KE3DDB1HPFQAbKeNgJblRQ+lDsBE=";
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
