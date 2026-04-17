{ helpers }:
{
  version = 1;
  doc = ''
    The `apps` output provides commands available via `nix run`.
  '';
  roles.nix-run = { };
  appendSystem = true;
  defaultAttrPath = [ "default" ];
  inventory =
    output:
    helpers.mkChildren (
      builtins.mapAttrs (system: apps: {
        forSystems = [ system ];
        children = builtins.mapAttrs (appName: app: helpers.mkApp system app) apps;
      }) output
    );
}
