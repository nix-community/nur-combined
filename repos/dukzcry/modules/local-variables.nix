{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.environment.localVariables;
  path = "local-variables/";

  exportedEnvVars = variables:
    let
      absoluteVariables =
        mapAttrs (n: toList) variables;

      exportVariables =
        mapAttrsToList (n: v: ''export ${n}="${concatStringsSep ":" v}"'') absoluteVariables;
    in
      concatStringsSep "\n" exportVariables;
  extraFiles = files:
    let
      files' = mapAttrsToList (n: v: ''. /etc/${path}${n}'') files;
    in
      concatStringsSep "\n" files';
in {
  options.environment = {
    localVariables = mkOption {
      type = types.nullOr types.attrs;
      default = null;
    };
  };

  config = mkIf (cfg != null) {
    environment.etc = mapAttrs (name: value: {
      text = ''
        if [ ''$USER == '${name}' ]; then
          ${exportedEnvVars value}
        fi
      '';
      target = path + name;
    }) cfg;
    environment.extraInit = extraFiles cfg;
  };
}
