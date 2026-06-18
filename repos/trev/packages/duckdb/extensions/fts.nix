{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "fts";
  repo = "duckdb-fts";
  branch = "main";
  rev = "08ea9086c4c28275270f9c5bb5bbbac7604c8b78";
  hash = "sha256-wFzaycY+t48ZR6I/eFSeiN9V1EDv7e5+qqP0DqoDY6s=";
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
