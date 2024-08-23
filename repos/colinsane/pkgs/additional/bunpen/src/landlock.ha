// vim: set shiftwidth=2 :
use log;
use rt;

fn access_fs_roughly_read() u64 = return
  LANDLOCK_ACCESS_FS_EXECUTE |
  LANDLOCK_ACCESS_FS_READ_FILE |
  LANDLOCK_ACCESS_FS_READ_DIR
;
fn access_fs_roughly_write() u64 = return
  LANDLOCK_ACCESS_FS_WRITE_FILE |
  LANDLOCK_ACCESS_FS_REMOVE_DIR |
  LANDLOCK_ACCESS_FS_REMOVE_FILE |
  LANDLOCK_ACCESS_FS_MAKE_CHAR |
  LANDLOCK_ACCESS_FS_MAKE_DIR |
  LANDLOCK_ACCESS_FS_MAKE_REG |
  LANDLOCK_ACCESS_FS_MAKE_SOCK |
  LANDLOCK_ACCESS_FS_MAKE_FIFO |
  LANDLOCK_ACCESS_FS_MAKE_BLOCK |
  LANDLOCK_ACCESS_FS_MAKE_SYM |
  LANDLOCK_ACCESS_FS_REFER |
  LANDLOCK_ACCESS_FS_TRUNCATE |
  LANDLOCK_ACCESS_FS_IOCTL_DEV
;

fn landlock_restrict() void = {
  let abi = landlock_create_ruleset(null, LANDLOCK_CREATE_RULESET_VERSION);
  log::printfln("found landlock version {}", abi);

  // determine the access modes we can ask this kernel to restrict on:
  let ruleset_attr = landlock_ruleset_attr {
    handled_access_fs = access_fs_roughly_read() | access_fs_roughly_write(),
    handled_access_net = LANDLOCK_ACCESS_NET_BIND_TCP | LANDLOCK_ACCESS_NET_CONNECT_TCP,
  };
  if (abi == 1) {
    ruleset_attr.handled_access_fs &= ~LANDLOCK_ACCESS_FS_REFER;
  };
  if (abi <= 2) {
    ruleset_attr.handled_access_fs &= ~LANDLOCK_ACCESS_FS_TRUNCATE;
  };
  if (abi <= 3) {
    ruleset_attr.handled_access_net &= ~(LANDLOCK_ACCESS_NET_BIND_TCP | LANDLOCK_ACCESS_NET_CONNECT_TCP);
  };
  if (abi <= 4) {
    ruleset_attr.handled_access_fs &= ~LANDLOCK_ACCESS_FS_IOCTL_DEV;
  };
  landlock_create_ruleset(&ruleset_attr, 0);

  // TODO: compute fs and net resource handles and call `landlock_add_rule`, `landlock_restrict_self`
  log::println("landlock_restrict: UNFINISHED");
};
