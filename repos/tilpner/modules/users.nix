{ config, options, lib, ... }: with lib; {
  options.users = {
    primary = mkOption {
      type = options.users.users.type.functor.wrapped;
      default = {};
    };

    primaryUserNames = mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };

  config.users.users = foldl mergeAttrs {}
    (flip map config.users.primaryUserNames (name: {
      ${name} = mkAliasDefinitions options.users.primary;
    }));
}
