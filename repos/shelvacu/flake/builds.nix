{
  flake-parts-lib,
  lib,
  vaculib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
  flakeConfig = config;
  allowedSystems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
  buildModule =
    { name, config, ... }:
    let
      buildConfig = config;
    in
    {
      options = {
        fullName = mkOption {
          type = types.str;
          default = name;
        };
        aliases = mkOption {
          type = types.listOf (types.either types.str (types.listOf types.str));
          default = [ ];
        };
        primarySystem = mkOption {
          type = types.enum allowedSystems;
          default = "x86_64-linux";
        };
        multiSystem = mkOption {
          type = types.bool;
          default = true;
        };
        putInPackages = mkOption {
          type = types.bool;
          default = false;
        };
        checkName = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        putInChecks = mkOption {
          type = types.bool;
          default = buildConfig.checkName != null;
          defaultText = "checkName != null";
        };
        broken = mkOption {
          type = types.bool;
          default = false;
        };
        derivations = mkOption {
          type = types.attrsOf types.package;
          default = lib.genAttrs buildConfig.allSystems (
            system: flakeConfig.flake.vacuBuildDerivations.${system}.${buildConfig.fullName}
          );
          defaultText = "(pulled from {option}`perSystem.\${system}.vacuBuildDerivations`)";
        };
        impure = mkOption {
          type = types.bool;
          default = false;
        };

        # out-options
        allSystems = mkOption {
          type = types.listOf (types.enum allowedSystems);
          readOnly = true;
        };
        allNames = mkOption {
          type = types.listOf types.str;
          readOnly = true;
        };
      };
      config = {
        # allSystems = lib.uniqueStrings ([ buildConfig.primarySystem ] ++ buildConfig.altSystems);
        allSystems = if buildConfig.multiSystem then allowedSystems else [ buildConfig.primarySystem ];
        allNames = lib.uniqueStrings ([ buildConfig.fullName ] ++ buildConfig.aliases);
      };
    };
  derivsForWhere =
    system: filterFn: nameFn:
    lib.pipe flakeConfig.vacuBuilds [
      builtins.attrValues
      (builtins.filter (
        buildConfig: (builtins.elem system buildConfig.allSystems) && (filterFn buildConfig)
      ))
      (map (
        buildConfig:
        let
          drv = buildConfig.derivations.${system};
        in
        if nameFn == null then
          map (name: lib.nameValuePair name drv) buildConfig.allNames
        else
          lib.singleton (lib.nameValuePair (nameFn buildConfig) drv)
      ))
      (map builtins.listToAttrs)
      vaculib.unionOfDisjointList
    ];
  systemNames = (lib.genAttrs allowedSystems (x: x)) // rec {
    x86 = "x86_64-linux";
    x86_64 = x86;
    arm = "aarch64-linux";
    arm64 = arm;
    aarch64 = arm;
  };
in
{
  imports = lib.singleton (
    flake-parts-lib.mkTransposedPerSystemModule {
      name = "vacuBuildDerivations";
      option = mkOption {
        type = types.attrsOf types.package;
        default = { };
      };
      file = ./builds.nix;
    }
  );
  options.vacuBuilds = mkOption {
    type = types.attrsOf (types.submodule buildModule);
    default = { };
  };
  config.perSystem =
    { system, ... }:
    let
      derivsWhere = derivsForWhere system;
    in
    {
      packages = derivsWhere (cfg: cfg.putInPackages) null;
      checks = derivsWhere (cfg: cfg.putInChecks && !cfg.broken) (
        cfg: if cfg.checkName != null then cfg.checkName else cfg.fullName
      );
    };
  options.flake.qb = lib.mkOption {
    type = types.lazyAttrsOf types.package;
    readOnly = true;
  };
  config.flake.qb = lib.pipe flakeConfig.vacuBuilds [
    (builtins.mapAttrs (
      debugName: buildConfig:
      lib.mapCartesianProduct
        (
          { systemName, buildName }:
          let
            system = if systemName == null then buildConfig.primarySystem else systemNames.${systemName};
            name = buildName + (lib.optionalString (systemName != null) "-${systemName}");
          in
          lib.optionalAttrs (builtins.elem system buildConfig.allSystems) {
            ${name} = buildConfig.derivations.${system};
          }
        )
        {
          systemName = [ null ] ++ (builtins.attrNames systemNames);
          buildName = buildConfig.allNames;
        }
    ))
    builtins.attrValues
    lib.flatten
    vaculib.unionOfDisjointList
  ];

  options.flake.vacuBuilds = vaculib.mkOutOption flakeConfig.vacuBuilds;
}
