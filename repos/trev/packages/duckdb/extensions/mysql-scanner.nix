{
  callPackage,
  mariadb-connector-c,
}:

(callPackage ./generic.nix { }) {
  name = "mysql_scanner";
  repo = "duckdb-mysql";
  branch = "v1.5-variegata";
  rev = "37006e53a58ddc31eeb96ff95c21f3196e27fcf2";
  hash = "sha256-tJhJE8nDlQUJO9vfwZo5mx8hIRgO4idJH6ftldKcFUQ=";
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
