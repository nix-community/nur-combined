{ config, options, lib, ... }:

with lib;
let
  envFiles = options.environment.files.type.getSubOptions {};
  envFilesFiles = envFiles.files.type.functor.wrapped;
  envFilesDirectories = envFiles.directories.type.functor.wrapped;

  relevantUser = user: user.files != {} || user.directories != {};
in {
  imports = [ ./files.nix ];

  options.users.users = mkOption {
    type = with types; loaOf (submodule {
      options.files = mkOption {
        type = types.attrsOf envFilesFiles;
        default = {};
      };

      options.directories = mkOption {
        type = types.attrsOf envFilesDirectories;
        default = {};
      };
    });
  };

  config.environment.files = mkMerge (flip mapAttrsToList config.users.users
    (name: user: optionalAttrs (relevantUser user) {
      "user-${name}" = {
        root = user.home;
        inherit (user) files directories;
      };
    }));
}
