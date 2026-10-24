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
  rev = "4e066c17e2d1f24625baff4c62430d68ceb4e41f";
  hash = "sha256-bhLRwuN8SfW1oDCaiRpdZDh3kTSndiPs+sHoXQ+MSrc=";
  loadOptions = [
    "SOURCE_DIR \${PROJECT_SOURCE_DIR}/extension_external/spatial"
    "INCLUDE_DIR \${PROJECT_SOURCE_DIR}/extension_external/spatial/src/spatial"
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
      --replace-fail "VSIFileManager::InstallHandler(client_prefix, fs_handler.get());" "VSIFileManager::InstallHandler(client_prefix, std::shared_ptr<VSIFilesystemHandler>(fs_handler.get(), [](VSIFilesystemHandler *) {}));" \
      --replace-fail "size_t Read(void *buffer, size_t size, size_t count) override {" "size_t Read(void *buffer, size_t nBytes) override {
        return Read(buffer, 1, nBytes);
      }

      size_t Read(void *buffer, size_t size, size_t count) {" \
      --replace-fail "size_t Write(const void *buffer, size_t size, size_t count) override {" "size_t Write(const void *buffer, size_t nBytes) override {
        return Write(buffer, 1, nBytes);
      }

      size_t Write(const void *buffer, size_t size, size_t count) {"

    # nixpkgs sqlite is built without SQLITE_USE_URI, so the embedded proj.db URI needs the flag
    substituteInPlace extension_external/spatial/src/spatial/modules/proj/proj_module.cpp \
      --replace-fail "SQLITE_OPEN_READONLY, \"memvfs\")" "SQLITE_OPEN_READONLY | SQLITE_OPEN_URI, \"memvfs\")"

    # the bundled proj.db is from proj 9.1.1, embed the one matching the linked proj instead
    python3 - ${proj}/share/proj/proj.db extension_external/spatial/src/spatial/modules/proj/proj_db.c <<'PY'
    import sys

    data = open(sys.argv[1], "rb").read()
    with open(sys.argv[2], "w") as out:
        out.write("unsigned char proj_db[] = {\n")
        for i in range(0, len(data), 12):
            out.write("  " + ", ".join(f"0x{b:02x}" for b in data[i : i + 12]) + ",\n")
        out.write(f"}};\nunsigned int proj_db_len = {len(data)};\n")
    PY

    substituteInPlace extension_external/spatial/src/spatial/util/math.cpp \
      --replace-fail "#if SPATIAL_USE_GEOS" "#if 0"
  '';
}
