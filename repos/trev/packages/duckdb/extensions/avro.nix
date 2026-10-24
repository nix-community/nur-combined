{
  callPackage,
  jansson,
  snappy,
  xz,
  zlib,
}:

(callPackage ./generic.nix { }) {
  name = "avro";
  repo = "duckdb-avro";
  rev = "758fb6063cbb6da49b2e1c16c4044cfcafefc52f";
  hash = "sha256-apH/rqm9mAhpRrXJSb5t8pcCauHoWMi0tz53SYlmymo=";
  # avro-c is built from the third_party/avro-c submodule
  fetchSubmodules = true;
  duckdbBuildInputs = [
    jansson
    snappy
    xz
    zlib
  ];
  duckdbPostPatch = ''
    # avro-c's cmake runs version.sh, which expects /bin/bash
    patchShebangs extension_external/avro/third_party/avro-c/lang/c/version.sh

    # avro-c predates C23, which newer compilers default to
    substituteInPlace extension_external/avro/CMakeLists.txt \
      --replace-fail "# Add avro-c from submodule" "set(CMAKE_C_STANDARD 17)
    set(CMAKE_C_FLAGS \"\''${CMAKE_C_FLAGS} -Wno-incompatible-pointer-types\")
    # Add avro-c from submodule"
  '';
}
