{ helpers }:
{
  version = 1;
  doc = ''
    The `schemas` flake output is used to define and document flake outputs.
    For the expected format, consult the Nix manual.
  '';
  inventory =
    output:
    {
      isLegacy = true; # not actually legacy, used to hide by default
    }
    // helpers.mkChildren (
      builtins.mapAttrs (schemaName: schemaDef: {
        shortDescription = "A schema checker for the `${schemaName}` flake output";
        evalChecks.isValidSchema =
          schemaDef.version or 0 == 1
          && schemaDef ? doc
          && builtins.isString (schemaDef.doc)
          && schemaDef ? inventory
          && builtins.isFunction (schemaDef.inventory);
        what = "flake schema";
      }) output
    );
}
