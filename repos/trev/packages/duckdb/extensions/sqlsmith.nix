{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "sqlsmith";
  repo = "duckdb-sqlsmith";
  branch = "main";
  rev = "ed4252b074934adc75a65b17332947d4edad8a45";
  hash = "sha256-yMQF7kVvxHHeIDxixMajumtL5BDvi82aOO8Qqkl3eUg=";
  loadOptions = [ "DONT_LINK" ];
  duckdbPostPatch = ''
    substituteInPlace extension_external/sqlsmith/src/statement_simplifier.cpp \
      --replace-fail '#include "duckdb/parser/query_node/insert_query_node.hpp"' "" \
      --replace-fail '#include "duckdb/parser/query_node/update_query_node.hpp"' "" \
      --replace-fail '#include "duckdb/parser/query_node/delete_query_node.hpp"' "" \
      --replace-fail "stmt.node->cte_map" "stmt.cte_map" \
      --replace-fail "stmt.node->select_statement" "stmt.select_statement" \
      --replace-fail "stmt.node->returning_list" "stmt.returning_list" \
      --replace-fail "stmt.node->condition" "stmt.condition" \
      --replace-fail "stmt.node->using_clauses" "stmt.using_clauses" \
      --replace-fail "stmt.node->from_table" "stmt.from_table" \
      --replace-fail "stmt.node->set_info" "stmt.set_info" \
      --replace-fail "cte_child.second->query_node" "cte_child.second->query->node"

    substituteInPlace extension_external/sqlsmith/src/statement_generator.cpp \
      --replace-fail '#include "duckdb/parser/query_node/delete_query_node.hpp"' "" \
      --replace-fail "delete_statement->node->table" "delete_statement->table" \
      --replace-fail "cte->query_node = std::move(unique_ptr_cast<SQLStatement, SelectStatement>(GenerateSelect())->node);" "cte->query = unique_ptr_cast<SQLStatement, SelectStatement>(GenerateSelect());" \
      --replace-fail "table_function.GetArguments().size()" "table_function.arguments.size()" \
      --replace-fail "actual_function.GetSignature().GetParameters()" "actual_function.arguments" \
      --replace-fail "actual_function.GetSignature().GetParameterCount()" "actual_function.arguments.size()" \
      --replace-fail "actual_function.GetSignature().GetVarArgs().id() != LogicalTypeId::INVALID" "actual_function.HasVarArgs()" \
      --replace-fail "actual_function.GetVarArgs().id() != LogicalTypeId::INVALID" "actual_function.HasVarArgs()" \
      --replace-fail "function->GetSignature().GetParameterCount()" "function->arguments.size()" \
      --replace-fail "base_function.GetName()" "base_function.name" \
      --replace-fail "base_function.GetSignature().GetParameters()" "base_function.arguments" \
      --replace-fail "arg.GetType()" "arg" \
      --replace-fail "param.GetType()" "param" \
      --replace-fail "CatalogType::WINDOW_FUNCTION_ENTRY" "CatalogType::INVALID" \
      --replace-fail "make_uniq<WindowExpression>(SYSTEM_CATALOG, DEFAULT_SCHEMA, std::move(name))" "make_uniq<WindowExpression>(type, SYSTEM_CATALOG, DEFAULT_SCHEMA, std::move(name))"

    substituteInPlace extension_external/sqlsmith/src/sqlsmith_extension.cpp \
      --replace-fail "SetChildCardinality" "SetCardinality"
  '';
}
