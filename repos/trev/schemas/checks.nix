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
  inventory =
    output:
    helpers.mkChildren (
      builtins.mapAttrs (systemType: checksForSystem: {
        forSystems = [ systemType ];
        children = builtins.mapAttrs (
          _: check:
          let
            package = helpers.mkPackage true "Test" systemType check;
          in
          # Don't build stubs for checks that mkFlake found unavailable on this system
          if check.skipped or false then
            package
            // {
              isFlakeCheck = false;
              what = "Skipped test";
            }
          else
            package
        ) checksForSystem;
      }) output
    );
}
