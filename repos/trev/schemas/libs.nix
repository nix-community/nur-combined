{ helpers }:
{
  version = 1;
  doc = ''
    The `libs` flake output contains helper functions.
  '';
  inventory =
    output:
    helpers.mkChildren (
      builtins.mapAttrs (
        name: def:
        if builtins.isFunction def then
          {
            shortDescription = "Helper function";
            what = "Helper function";
          }
        else
          {
            forSystems = [ name ];
            children = builtins.mapAttrs (_: _: {
              shortDescription = "Helper function";
              what = "Helper function";
            }) def;
          }
      ) output
    );
}
