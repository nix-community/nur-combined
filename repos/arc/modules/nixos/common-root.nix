{ lib, config, commonRoot, ... }: with lib; {
  config = {
    _module.args.commonRoot = {
      __functor = self: other: self.getConfig == other.commonRoot.getConfig or null;
      getConfig = _: config;

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
