{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "fts";
  repo = "duckdb-fts";
  branch = "main";
  rev = "50ba657efa1fb8e3daf7eab95eb1896db6d64efb";
  hash = "sha256-Uv5QlCxaZk5e/6u7awr00G6zGO1Vo+l2YlcXGEk35fU=";
  loadOptions = [ "DONT_LINK" ];
  duckdbPostPatch = ''
    substituteInPlace extension_external/fts/src/fts_indexing.cpp \
      --replace-fail '#include "duckdb/common/sql_identifier.hpp"' '#include "duckdb/parser/keyword_helper.hpp"' \
      --replace-fail "SQLIdentifier::ToString" "KeywordHelper::WriteOptionallyQuoted" \
      --replace-fail "SQLString::ToString" "KeywordHelper::WriteQuoted" \
      --replace-fail ".GetIdentifierName()" "" \
      --replace-fail "Identifier(GetFTSSchemaName(qname))" "GetFTSSchemaName(qname)" \
      --replace-fail "Identifier(name)" "name" \
      --replace-fail "Identifier(col_name)" "col_name" \
      --replace-fail "storage_manager.GetStorageVersion() >= StorageVersion::V2_0_0" "false"
  '';
}
