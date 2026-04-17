{ helpers }:
let
  mkApp = system: app: {
    forSystems = [ system ];
    evalChecks.isValidApp =
      app ? type
      && app.type == "app"
      && app ? program
      && builtins.isString app.program
      &&
        removeAttrs app [
          "type"
          "program"
          "meta"
        ] == { };
    what = app.meta.script or "App";
    shortDescription = app.meta.description or "";
  };
in
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
        children = builtins.mapAttrs (appName: app: mkApp system app) apps;
      }) output
    );
}
