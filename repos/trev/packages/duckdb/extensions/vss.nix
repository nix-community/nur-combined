{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "vss";
  repo = "duckdb-vss";
  branch = "v1.5-variegata";
  rev = "b833341c8737fd3f3558c7720cc575ae8fc82598";
  hash = "sha256-txtsTm3OGNDGI5jeMvy9JA7R6pzb22gy5ArxTVc2Usw=";
  loadOptions = [ "DONT_LINK" ];
  duckdbPostPatch = ''
    substituteInPlace \
      extension_external/vss/src/hnsw/hnsw_index.cpp \
      extension_external/vss/src/include/hnsw/hnsw_index.hpp \
      --replace-fail "CommitDrop" "ResetStorage"
  '';
}
