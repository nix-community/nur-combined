{
  lib,
  newScope,
}:

lib.makeScope newScope (self: {
  # "Access Control List", only it's just a user:group and file mode
  # compatible with `chown` and `chmod`
  aclMod = {
    options = {
      user = lib.mkOption {
        type = lib.types.str;  # TODO: use uid?
      };
      group = lib.mkOption {
        type = lib.types.str;
      };
      mode = lib.mkOption {
        type = lib.types.str;
      };
    };
  };
  acl = lib.types.submodule self.aclMod;

  # this is acl, but doesn't require to be fully specified.
  # a typical use case is when there's a complete acl, and the user
  # wants to override just one attribute of it.
  aclOverrideMod = {
    options = {
      user = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      group = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      mode = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };
  };
  aclOverride = lib.types.submodule self.aclOverrideMod;
})
