{ lib, config, options, commonRoot, ... }: with lib; {
  config = {
    ${if options ? home-manager.users then "home-manager" else null} = {
      sharedModules = [
        commonRoot.propagate
      ];
    };
    _module.args.commonRoot = {
      __functor = self: other: self.getConfig == other.commonRoot.getConfig or null;
      getConfig = { }: config;

      tag = { ... }: {
        options = {
          commonRoot = mkOption {
            type = types.unspecified;
            internal = true;
          };
        };
        config = {
          inherit commonRoot;
        };
      };

      propagate = { ... }: {
        config._module.args = {
          inherit commonRoot;
        };
      };
    };
  };
}
