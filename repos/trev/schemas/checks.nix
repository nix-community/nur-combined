{ helpers }:
{
  version = 1;
  doc = ''
    The `checks` flake output contains derivations that will be built by `nix flake check`.
  '';
  roles = {
    nix-build = { };
    nix-run = { };
  };
  inventory = helpers.derivationsInventory "Test" true;
}
