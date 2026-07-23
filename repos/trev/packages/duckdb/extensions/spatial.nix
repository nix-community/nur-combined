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
  rev = "eb1e57c9d92c0f3f76eb03eaa52c315090f328cc";
  hash = "sha256-Z1jE1z1ppR0YKgYLx9zLs8QuWEuM3iz+tpPqj6EZBKQ=";
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
      --replace-fail "size_t Read(void *buffer, size_t size, size_t count) override {" "size_t Read(void *buffer, size_t nBytes) override {
        return Read(buffer, 1, nBytes);
      }

      size_t Read(void *buffer, size_t size, size_t count) {" \
      --replace-fail "size_t Write(const void *buffer, size_t size, size_t count) override {" "void ClearErr() override {
      }

      int Error() override {
        return FALSE;
      }

      size_t Write(const void *buffer, size_t nBytes) override {
        return Write(buffer, 1, nBytes);
      }

      size_t Write(const void *buffer, size_t size, size_t count) {"

    substituteInPlace extension_external/spatial/src/spatial/util/math.cpp \
      --replace-fail "#if SPATIAL_USE_GEOS" "#if 0"

    substituteInPlace \
      extension_external/spatial/src/spatial/index/rtree/rtree_index.cpp \
      extension_external/spatial/src/spatial/index/rtree/rtree_index.hpp \
      --replace-fail "CommitDrop" "ResetStorage"
  '';
}
