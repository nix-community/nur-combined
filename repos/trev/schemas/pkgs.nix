{ helpers }:
{
  version = 1;
  doc = ''
    The `pkgs` flake output contains the modified nixpkgs package set used by the project.
    Primarily consumed by nixd to provide package & lib completion/information from it:
    `(builtins.getFlake (builtins.toString ./.)).outputs.pkgs.${builtins.currentSystem}`
  '';
  appendSystem = true;
  defaultAttrPath = [ ];
  inventory =
    output:
    helpers.mkChildren (
      builtins.mapAttrs (system: formatter: {
        forSystems = [ system ];
        what = "Packages";
        shortDescription = "The modified nixpkgs package set used by the project";
        derivationAttrPath = [ ];
        isFlakeCheck = false;
      }) output
    );
}
