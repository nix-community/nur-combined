{ helpers }:
{
  version = 1;
  doc = ''
    The `bundlers` flake output defines ["bundlers"](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-bundle) that transform derivation outputs into other formats, typically self-extracting executables or container images.
  '';
  roles.nix-bundler = { };
  appendSystem = true;
  defaultAttrPath = [ "default" ];
  inventory =
    output:
    helpers.mkChildren (
      builtins.mapAttrs (
        system: bundlers:
        let
          forSystems = [ system ];
        in
        {
          inherit forSystems;
          children = builtins.mapAttrs (bundlerName: bundler: {
            inherit forSystems;
            evalChecks.isValidBundler = builtins.isFunction bundler;
            what = "Bundler";
          }) bundlers;
        }
      ) output
    );
}
