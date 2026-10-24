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
  rev = "f7fc0d42716534aa5ad48626d21ced9807b33967";
  hash = "sha256-pTZua/YlpapRAHwJzN0eAuueh7KhF5HknuRULt60rHA=";
  fetchSubmodules = true;
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
