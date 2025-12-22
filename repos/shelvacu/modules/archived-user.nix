{ ... }:
{
  # a dummy user/group that I can set on folders to indicate that they shouldn't be touched
  users.users.archived = {
    # these are "sealed", "SEAL" = 5341
    uid = 5341;
    isSystemUser = true;
    group = "archived";
  };
  users.groups.archived.gid = 5341;
}
