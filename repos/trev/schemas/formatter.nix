{ helpers }:
{
  version = 1;
  doc = ''
    The `formatter` output specifies the package to use to format the project.
  '';
  roles.nix-fmt = { };
  appendSystem = true;
  defaultAttrPath = [ ];
  inventory =
    output:
    helpers.mkChildren (
      builtins.mapAttrs (system: formatter: {
        forSystems = [ system ];
        shortDescription = formatter.meta.description or "";
        derivationAttrPath = [ ];
        what = "Formatter";
        isFlakeCheck = false;
      }) output
    );
}
