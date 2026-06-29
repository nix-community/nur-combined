{
  callPackage,
  mariadb-connector-c,
}:

(callPackage ./generic.nix { }) {
  name = "mysql_scanner";
  repo = "duckdb-mysql";
  branch = "v1.5-variegata";
  rev = "0e3c49a933d9e5b258a3a12ec3cf4c6a984303a5";
  hash = "sha256-D5LlZpyXxBEBOJ4LRvmEO/P/2cd91jG28kj1K5XZlZA=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [
    mariadb-connector-c
    mariadb-connector-c.dev
  ];
  duckdbPostPatch = ''
    substituteInPlace extension_external/mysql_scanner/CMakeLists.txt \
      --replace-fail "find_package(libmariadb REQUIRED)" \
        "set(MYSQL_LIBRARIES ${mariadb-connector-c}/lib/mariadb/libmariadb.so.3)"

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
