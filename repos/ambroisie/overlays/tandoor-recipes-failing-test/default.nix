_self: super:
{
  tandoor-recipes = super.tandoor-recipes.overridePythonAttrs (oa: {
    disabledTests = (oa.disabledTests or [ ]) ++ [
      "test_search_count"
      "test_url_import_regex_replace"
    ];
  });
}
