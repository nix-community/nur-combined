let
  mutablePathModule = { lib, state, config, ... }: with lib; {
    options = {
      name = mkOption {
        type = types.str;
        default = builtins.baseNameOf config.path;
      };

      path = mkOption {
        type = types.path;
      };

      owner = mkOption {
        type = types.str;
        default = state.owner;
      };
      group = mkOption {
        type = types.str;
        default = state.group;
      };

      exclude = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };

      excludeExtract = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };
in { config, name, lib, ... }: with lib; {
  options = {
    enable = mkEnableOption "${name} mutable state" // {
      default = true;
    };
    instanced = mkOption {
      type = types.bool;
      default = false;
      description = "Set if the service may be deployed to multiple machines in a network";
    };
    name = mkOption {
      type = types.str;
      default = name;
    };
    # TODO: pre/post backup actions/commands...
    databases = {
      postgresql = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
    owner = mkOption {
      type = types.str;
      default = "root";
    };
    group = mkOption {
      type = types.str;
      default = "root";
    };
    serviceNames = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    paths = mkOption {
      type = let
        mutablePathType = types.submodule [
          mutablePathModule
          ({ ... }: {
            _module.args.state = config;
          })
        ];
      in types.listOf (types.coercedTo types.path (path: { inherit path; }) mutablePathType);
      default = [ ];
    };
  };
}
