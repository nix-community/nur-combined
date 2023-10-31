_self: prev:
{
  tandoor-recipes = prev.tandoor-recipes.overrideAttrs (oa: {
    patches = (oa.patches or [ ]) ++ [
      # https://github.com/TandoorRecipes/recipes/pull/2706
      ./bump-allauth.patch
    ];
  });
}
