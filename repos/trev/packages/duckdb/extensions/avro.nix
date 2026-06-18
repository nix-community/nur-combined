{
  lib,
  avro-c,
  callPackage,
  fetchFromGitHub,
  jansson,
  snappy,
  xz,
  zlib,
}:

let
  duckdbAvroC = avro-c.overrideAttrs (oldAttrs: {
    version = "1.11.3-duckdb";

    src = fetchFromGitHub {
      owner = "duckdb";
      repo = "duckdb-avro-c";
      rev = "8af400279c445a81b8552a7670d8c1ebd92ba34a";
      hash = "sha256-LaRdDinWkoXjUp/Z8Fyi5gQ2syB8ptaPA/y1oO+mYrA=";
    };

    sourceRoot = "source/lang/c";

    cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
      (lib.cmakeBool "BUILD_EXAMPLES" false)
      (lib.cmakeBool "BUILD_TESTS" false)
      (lib.cmakeBool "BUILD_DOCS" false)
      (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu17 -Wno-incompatible-pointer-types";
  });
in

(callPackage ./generic.nix { }) {
  name = "avro";
  repo = "duckdb-avro";
  branch = "v1.5-variegata";
  rev = "f9d590297485f0318f480372c70bdd852826e258";
  hash = "sha256-1JiLOHgnqd7Oao3S8W2/erlqi8fgvpbHXSURhigBQSM=";
  duckdbBuildInputs = [
    duckdbAvroC
    jansson
    snappy
    xz
    zlib
  ];
  duckdbPostPatch = ''
    substituteInPlace extension_external/avro/CMakeLists.txt \
      --replace-fail "find_library(AVRO_LIBRARY libavro.a REQUIRED)" "find_library(AVRO_LIBRARY avro REQUIRED)" \
      --replace-fail "find_library(JANSSON_LIBRARY libjansson.a REQUIRED)" "find_library(JANSSON_LIBRARY jansson REQUIRED)" \
      --replace-fail "find_library(LZMA_LIBRARY liblzma.a REQUIRED)" "find_library(LZMA_LIBRARY lzma REQUIRED)" \
      --replace-fail "find_library(ZLIB_LIBRARY libz.a REQUIRED)" "find_library(ZLIB_LIBRARY z REQUIRED)"
  '';
}
