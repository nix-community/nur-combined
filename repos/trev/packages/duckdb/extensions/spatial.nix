{
  callPackage,
  curl,
  expat,
  gdal,
  geos,
  openssl,
  proj,
  sqlite,
  zlib,
}:

(callPackage ./generic.nix { }) {
  name = "spatial";
  repo = "duckdb-spatial";
  branch = "v1.5-variegata";
  rev = "5974620688ecf5f085a755929c4fda3d17f62866";
  hash = "sha256-UGuGNvgkufG1fz1cviNOcHE8D12MlOozfk3ZW6/K7L4=";
  loadOptions = [
    "DONT_LINK"
    "INCLUDE_DIR src/spatial"
  ];
  duckdbBuildInputs = [
    curl
    expat
    gdal
    geos
    openssl
    proj
    sqlite
    zlib
  ];
  duckdbPostPatch = ''
    substituteInPlace extension_external/spatial/CMakeLists.txt \
      --replace-fail "set(ZLIB_USE_STATIC_LIBS ON)" "set(ZLIB_USE_STATIC_LIBS OFF)" \
      --replace-fail "set(OPENSSL_USE_STATIC_LIBS ON)" "set(OPENSSL_USE_STATIC_LIBS OFF)" \
      --replace-fail "find_package(unofficial-sqlite3 CONFIG REQUIRED)" "find_package(SQLite3 REQUIRED)" \
      --replace-fail "unofficial::sqlite3::sqlite3" "SQLite::SQLite3"

    substituteInPlace extension_external/spatial/src/spatial/modules/gdal/gdal_module.cpp \
      --replace-fail "OGRRegisterAllInternal();" "GDALAllRegister();" \
      --replace-fail "VSIVirtualHandle *Open(" "VSIVirtualHandleUniquePtr Open(" \
      --replace-fail "return new DuckDBFileHandle(std::move(file));" "return VSIVirtualHandleUniquePtr(new DuckDBFileHandle(std::move(file)));" \
      --replace-fail "bool IsLocal(const char *gdal_file_path) override" "bool IsLocal(const char *gdal_file_path) const override" \
      --replace-fail "int Rename(const char *oldpath, const char *newpath) override" "int Rename(const char *oldpath, const char *newpath, GDALProgressFunc, void *) override" \
      --replace-fail "size_t Write(const void *buffer, size_t size, size_t count) override {" "void ClearErr() override {
      }

      int Error() override {
        return FALSE;
      }

      size_t Write(const void *buffer, size_t size, size_t count) override {"

    substituteInPlace extension_external/spatial/src/spatial/util/math.cpp \
      --replace-fail "#if SPATIAL_USE_GEOS" "#if 0"
  '';
}
