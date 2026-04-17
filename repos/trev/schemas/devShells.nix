{ helpers }:
{
  version = 1;
  doc = ''
    The `devShells` flake output contains derivations that provide a development environment for `nix develop`.
  '';
  roles.nix-develop = { };
  appendSystem = true;
  defaultAttrPath = [ "default" ];
  inventory = helpers.derivationsInventory "Development environment" false;
}
