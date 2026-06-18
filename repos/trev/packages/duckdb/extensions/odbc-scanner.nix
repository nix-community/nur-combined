{
  callPackage,
  unixodbc,
}:

(callPackage ./generic.nix { }) {
  name = "odbc_scanner";
  repo = "odbc-scanner";
  branch = "main";
  rev = "274a3307341dcafd62471c09b45c5d858d6c95cc";
  hash = "sha256-I3LtOipBN+WuYiuWvt9sptc7mVglutxo/lMQCvsoz8o=";
  loadOptions = [ "DONT_LINK" ];
  duckdbBuildInputs = [ unixodbc ];
  duckdbPostPatch = ''
    python3 - <<'PY'
    from pathlib import Path

    path = Path("extension_external/odbc_scanner/CMakeLists.txt")
    text = path.read_text()
    old = (
        "    find_package(Git)\n"
        "    if(Git_FOUND)\n"
        "        execute_process(\n"
        "            COMMAND $" + "{GIT_EXECUTABLE} rev-parse --short=10 HEAD\n"
        "            WORKING_DIRECTORY $" + "{CMAKE_CURRENT_SOURCE_DIR}\n"
        "            OUTPUT_VARIABLE $" + "{EXTENSION_NAME}_GIT_COMMIT_HASH\n"
        "            OUTPUT_STRIP_TRAILING_WHITESPACE)\n"
        "    else()\n"
        "        message(FATAL_ERROR \"Unable to get Git version for extension: $" + "{EXTENSION_NAME}\")\n"
        "    endif()\n"
    )
    new = "    set(odbc_scanner_GIT_COMMIT_HASH 274a330734)\n"
    if old not in text:
        raise SystemExit(f"pattern not found in {path}")
    path.write_text(text.replace(old, new))
    PY
  '';
}
