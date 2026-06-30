{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "fts";
  repo = "duckdb-fts";
  branch = "main";
  rev = "ec028bb5678b2c5932edbd24f902c6a76da30b5e";
  hash = "sha256-4WU+xel+BqctG6c9MvowlG5Va4KjPm3V756FW8sqPgU=";
  loadOptions = [ "DONT_LINK" ];
  duckdbPostPatch = ''
    substituteInPlace extension_external/fts/src/fts_indexing.cpp \
      --replace-fail '#include "duckdb/common/sql_identifier.hpp"' '#include "duckdb/parser/keyword_helper.hpp"' \
      --replace-fail "SQLIdentifier::ToString" "KeywordHelper::WriteOptionallyQuoted" \
      --replace-fail "SQLString::ToString" "KeywordHelper::WriteQuoted" \
      --replace-fail ".GetIdentifierName()" "" \
      --replace-fail "sw_qname.Catalog()" "sw_qname.catalog" \
      --replace-fail "sw_qname.Schema()" "sw_qname.schema" \
      --replace-fail "sw_qname.Name()" "sw_qname.name" \
      --replace-fail "qname.SchemaMutable()" "qname.schema" \
      --replace-fail "qname.Catalog()" "qname.catalog" \
      --replace-fail "qname.Schema()" "qname.schema" \
      --replace-fail "qname.Name()" "qname.name" \
      --replace-fail "Identifier(GetFTSSchemaName(qname))" "GetFTSSchemaName(qname)" \
      --replace-fail "Identifier(name)" "name" \
      --replace-fail "Identifier(column_name)" "column_name" \
      --replace-fail "Identifier(doc_id)" "doc_id" \
      --replace-fail "Identifier(col_name)" "col_name" \
      --replace-fail "storage_manager.GetStorageVersion() >= StorageVersion::V2_0_0" "false"
  '';
}
