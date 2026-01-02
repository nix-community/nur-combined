{
  lib,
  config,
  vacuModuleType,
  vaculib,
  ...
}:
let
  exposeTy =
    with lib.types;
    lazyAttrsOf (
      nullOr (oneOf [
        package
        str
        number
        bool
        exposeTy
      ])
    );

  builderCommands = lib.pipe config.vacu.expose [
    (lib.mapAttrsToListRecursiveCond (_path: attrs: !lib.isDerivation attrs) (
      path: val:
      assert lib.all (pathPart: (lib.match ".*/.*" pathPart) == null) path;
      ''
        # config.vacu.expose.${lib.showAttrPath path}
        vacu_expose_path="$out/vacu-expose/"${lib.escapeShellArg (lib.concatStringsSep "/" path)}
        mkdir -p -- "$(dirname -- "$vacu_expose_path")"
        ${
          if lib.isDerivation val then
            ''ln -s ${lib.escapeShellArg val} "$vacu_expose_path"''
          else if lib.isPath val then
            ''ln -s ${vaculib.path val} "$vacu_expose_path"''
          else if lib.isBool val then
            ''echo ${lib.boolToString val} > "$vacu_expose_path"''
          else
            ''printf '%s' ${lib.escapeShellArg (builtins.toString val)} > "$vacu_expose_path"''
        }
      ''
    ))
    (lib.concatStringsSep "\n")
  ];
in
{
  imports =
    [ ]
    ++ lib.optional (vacuModuleType == "nixos") {
      config.system = {
        systemBuilderCommands = config.vacu.exposeBuilderCommands;
        systemBuilderArgs.passthru = config.vacu.expose;
      };
    }
    ++ lib.optional (vacuModuleType == "nix-on-droid") {
      config.build = {
        activationPackageBuilderCommands = config.vacu.exposeBuilderCommands;
        activationPackageBuilderArgs.passthru = config.vacu.expose;
      };
    };
  options.vacu = {
    expose = lib.mkOption {
      type = exposeTy;
      default = { };
    };
    exposeBuilderCommands = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = builderCommands;
    };
  };
}
