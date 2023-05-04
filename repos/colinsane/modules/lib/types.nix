{ lib, ... }:

with lib;
rec {
  # "Access Control List", only it's just a user:group and file mode
  # compatible with `chown` and `chmod`
  aclMod = {
    options = {
      user = mkOption {
        type = types.str;  # TODO: use uid?
      };
      group = mkOption {
        type = types.str;
      };
      mode = mkOption {
        type = types.str;
      };
    };
  };
  acl = types.submodule aclMod;

  # this is acl, but doesn't require to be fully specified.
  # a typical use case is when there's a complete acl, and the user
  # wants to override just one attribute of it.
  aclOverrideMod = {
    options = {
      user = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      group = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      mode = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
  };
  aclOverride = types.submodule aclOverrideMod;
}
