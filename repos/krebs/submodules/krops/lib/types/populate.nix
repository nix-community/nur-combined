{ lib }: rec {

  source = lib.types.submodule ({ config, ... }: {
    options = {
      type = let
        known-types = lib.attrNames source-types;
        type-candidates = lib.filter (k: config.${k} != null) known-types;
      in lib.mkOption {
        default = if lib.length type-candidates == 1
                    then lib.head type-candidates
                    else throw "cannot determine type";
        type = lib.types.enum known-types;
      };
      file = lib.mkOption {
        apply = x:
          if lib.types.absolute-pathname.check x
            then { path = x; }
            else x;
        default = null;
        type = lib.types.nullOr (lib.types.either lib.types.absolute-pathname source-types.file);
      };
      git = lib.mkOption {
        default = null;
        type = lib.types.nullOr source-types.git;
      };
      pass = lib.mkOption {
        default = null;
        type = lib.types.nullOr source-types.pass;
      };
      pipe = lib.mkOption {
        apply = x:
          if lib.types.absolute-pathname.check x
            then { command = x; }
            else x;
        default = null;
        type = lib.types.nullOr (lib.types.either lib.types.absolute-pathname source-types.pipe);
      };
      symlink = lib.mkOption {
        apply = x:
          if lib.types.pathname.check x
            then { target = x; }
            else x;
        default = null;
        type = lib.types.nullOr (lib.types.either lib.types.pathname source-types.symlink);
      };
    };
  });

  source-types = {
    file = lib.types.submodule {
      options = {
        path = lib.mkOption {
          type = lib.types.absolute-pathname;
        };
      };
    };
    git = lib.types.submodule {
      options = {
        ref = lib.mkOption {
          type = lib.types.str; # TODO lib.types.git.ref
        };
        url = lib.mkOption {
          type = lib.types.str; # TODO lib.types.git.url
        };
      };
    };
    pass = lib.types.submodule {
      options = {
        dir = lib.mkOption {
          type = lib.types.absolute-pathname;
        };
        name = lib.mkOption {
          type = lib.types.pathname; # TODO relative-pathname
        };
      };
    };
    pipe = lib.types.submodule {
      options = {
        command = lib.mkOption {
          type = lib.types.absolute-pathname;
        };
      };
    };
    symlink = lib.types.submodule {
      options = {
        target = lib.mkOption {
          type = lib.types.pathname; # TODO relative-pathname
        };
      };
    };
  };

}
