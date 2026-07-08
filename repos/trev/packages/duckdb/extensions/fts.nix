{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "fts";
  repo = "duckdb-fts";
  branch = "main";
  rev = "44739b0897854764bdb3d0bb078018b812d5c0f9";
  hash = "sha256-JofC/C2FP4Wjw7Pw9kYNeNPXw1M7PZyf9PC/9KeQl7M=";
  loadOptions = [ "DONT_LINK" ];
  duckdbPostPatch = ''
    substituteInPlace extension_external/fts/src/fts_indexing.cpp \
      --replace-fail '#include "duckdb/common/sql_identifier.hpp"' '#include "duckdb/parser/keyword_helper.hpp"' \
      --replace-fail "SQLIdentifier::ToString" "KeywordHelper::WriteOptionallyQuoted" \
      --replace-fail "SQLString::ToString" "KeywordHelper::WriteQuoted" \
      --replace-fail ".GetIdentifierName()" "" \
      --replace-fail $'    return QualifiedName(\n        qname.Catalog(),\n        ClientData::Get(context).catalog_search_path->GetDefaultSchema(\n            qname.Catalog()),\n        qname.Name());' $'    qname.schema =\n        ClientData::Get(context).catalog_search_path->GetDefaultSchema(\n            qname.catalog);' \
      --replace-fail "qname.Catalog()" "qname.catalog" \
      --replace-fail "qname.Schema()" "qname.schema" \
      --replace-fail "qname.Name()" "qname.name" \
      --replace-fail $'  return Catalog::GetEntry<TableCatalogEntry>(\n             context, qname, OnEntryNotFound::RETURN_NULL) != nullptr;' $'  return Catalog::GetEntry<TableCatalogEntry>(\n             context, qname.catalog, qname.schema, qname.name,\n             OnEntryNotFound::RETURN_NULL) != nullptr;' \
      --replace-fail "Catalog::GetEntry<TableCatalogEntry>(context, qname)" "Catalog::GetEntry<TableCatalogEntry>(context, qname.catalog, qname.schema, qname.name)" \
      --replace-fail "Catalog::GetEntry<TableCatalogEntry>(context, sw_qname)" "Catalog::GetEntry<TableCatalogEntry>(context, sw_qname.catalog, sw_qname.schema, sw_qname.name)" \
      --replace-fail "Identifier(GetFTSSchemaName(qname))" "GetFTSSchemaName(qname)" \
      --replace-fail "Identifier(name)" "name" \
      --replace-fail "Identifier(column_name)" "column_name" \
      --replace-fail "Identifier(doc_id)" "doc_id" \
      --replace-fail "Identifier(col_name)" "col_name" \
      --replace-fail "storage_manager.GetStorageVersion() >= StorageVersion::V2_0_0" "false"
  '';
}
