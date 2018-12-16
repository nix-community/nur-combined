{ config, options, lib, ... }:

with lib;
let
  envFiles = builtins.elemAt options.environment.files.type.functor.wrapped.getSubModules 0;
  envFilesFiles = envFiles.submodule.options.files.type.functor.wrapped;
  envFilesDirectories = envFiles.submodule.options.directories.type.functor.wrapped;

  relevantUser = user: user.files != {} || user.directories != {};
in {
  imports = [ ./files.nix ];

  options.users.users = mkOption {
    options = [ {
      files = mkOption {
        type = types.attrsOf envFilesFiles;
        default = {};
      };

      directories = mkOption {
        type = types.attrsOf envFilesDirectories;
        default = {};
      };
    } ];
  };

  config.environment.files = mkMerge (flip mapAttrsToList config.users.users
    (name: user: optionalAttrs (relevantUser user) {
      "user-${name}" = {
        root = user.home;
        inherit (user) files directories;
      };
    }));
}
