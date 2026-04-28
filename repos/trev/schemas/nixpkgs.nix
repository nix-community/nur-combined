{ helpers }:
{
  version = 1;
  doc = ''
    The `nixpkgs` flake output contains the modified nixpkgs package set used by the project.
    Primarily consumed by nixd to provide package & lib completion/information from it:
    `(builtins.getFlake (builtins.toString ./.)).outputs.nixpkgs.''${builtins.currentSystem}`
  '';
  appendSystem = true;
  defaultAttrPath = [ ];
  inventory =
    output:
    helpers.mkChildren (
      builtins.mapAttrs (system: _: {
        forSystems = [ system ];
        what = "Package set";
        shortDescription = "The modified nixpkgs package set used by the project";
        isFlakeCheck = false;
      }) output
    );
}
