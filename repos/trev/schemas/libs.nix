{ }:
let
  mkChildren = children: { inherit children; };
in
{
  version = 1;
  doc = ''
    The `libs` flake output contains helper functions.
  '';
  inventory =
    output:
    mkChildren (
      builtins.mapAttrs (
        name: def:
        if builtins.isFunction def then
          {
            shortDescription = "helper function";
            what = "helper function";
          }
        else
          {
            forSystems = [ name ];
            children = builtins.mapAttrs (_: _: {
              shortDescription = "helper function";
              what = "helper function";
            }) def;
          }
      ) output
    );
}
