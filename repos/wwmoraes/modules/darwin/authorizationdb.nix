{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.system;
  writeAuthorizationDB = key: value: ''
    echo -n "${key} => ${value}: "
    security authorizationdb write ${key} ${value}
  '';
  authorizationDBToList =
    attrs: mapAttrsToList writeAuthorizationDB (filterAttrs (n: v: v != null) attrs);
in
{
  meta.maintainers = [
    maintainers.wwmoraes or "wwmoraes"
  ];

  options = {
    system.authorizationDB = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = {
        "system.privilege.taskport" = "authenticate-developer";
      };
      description = ''
        A set of MacOS Authorization DB rights and rules to apply.

        Make sure you know what you're doing; these can make or break your OS!
      '';
    };
  };
  config = {
    system.activationScripts.extraActivation.text = mkMerge [
      ''
        # Set Authorization DB
        echo >&2 "authorization DB..."
        ${concatStringsSep "\n" (authorizationDBToList cfg.authorizationDB)}
      ''
    ];
  };
}
