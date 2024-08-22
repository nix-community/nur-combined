// vim: set shiftwidth=2 :
use log;
use rt;

///// kernel consts. TODO: extract these from kernel headers, somehow.
// landlock syscall ID
const __NR_landlock_create_ruleset = 444u64;
// ---- landlock API constants ----
const LANDLOCK_CREATE_RULESET_VERSION = 1u64 << 0;
// landlock API: fs_access
const LANDLOCK_ACCESS_FS_EXECUTE: u64 = 1u64 << 0;
const LANDLOCK_ACCESS_FS_WRITE_FILE: u64 = 1u64 << 1;
const LANDLOCK_ACCESS_FS_READ_FILE: u64 = 1u64 << 2;
const LANDLOCK_ACCESS_FS_READ_DIR: u64 = 1u64 << 3;
const LANDLOCK_ACCESS_FS_REMOVE_DIR: u64 = 1u64 << 4;
const LANDLOCK_ACCESS_FS_REMOVE_FILE: u64 = 1u64 << 5;
const LANDLOCK_ACCESS_FS_MAKE_CHAR: u64 = 1u64 << 6;
const LANDLOCK_ACCESS_FS_MAKE_DIR: u64 = 1u64 << 7;
const LANDLOCK_ACCESS_FS_MAKE_REG: u64 = 1u64 << 8;
const LANDLOCK_ACCESS_FS_MAKE_SOCK: u64 = 1u64 << 9;
const LANDLOCK_ACCESS_FS_MAKE_FIFO: u64 = 1u64 << 10;
const LANDLOCK_ACCESS_FS_MAKE_BLOCK: u64 = 1u64 << 11;
const LANDLOCK_ACCESS_FS_MAKE_SYM: u64 = 1u64 << 12;
const LANDLOCK_ACCESS_FS_REFER: u64 = 1u64 << 13;
const LANDLOCK_ACCESS_FS_TRUNCATE: u64 = 1u64 << 14;
const LANDLOCK_ACCESS_FS_IOCTL_DEV: u64 = 1u64 << 15;
// landlock API: net_access
const LANDLOCK_ACCESS_NET_BIND_TCP: u64 = 1u64 << 0;
const LANDLOCK_ACCESS_NET_CONNECT_TCP: u64 = 1u64 << 1;

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

// lifted from <repo:kernel.org/linux:include/uapi/linux/landlock.h>
// argument to `sys_landlock_create_ruleset`.
// landlock ruleset definition.
type landlock_ruleset_attr = struct {
  // bitmask of handled filesystem actions
  handled_access_fs: u64,
  // bitmask of handled network actions
  handled_access_net: u64,
};

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
  landlock_create_ruleset(&ruleset_attr);

  // TODO: compute fs and net resource handles and call `landlock_restrict_self`
  log::println("landlock_restrict: UNFINISHED");
};

// checks the return value from a Linux syscall and, if found to be in error,
// returns the appropriate error. otherwise, returns the original value.
// borrowed from non-public hare internals: rt/+linux/errno.ha
fn wrap_return(r: u64) (rt::errno | u64) = {
  if (r > -4096: u64) {
    return (-(r: i64)): rt::errno;
  };
  return r;
};

// like `rt::syscall`, but maps negative return values to `errno`
fn syscall(num: u64, args: u64...) (rt::errno | u64) = {
  return wrap_return(rt::syscall(num, args...));
};

// landlock_create_ruleset syscall
fn landlock_create_ruleset(attr: nullable *landlock_ruleset_attr = null, flags: u64 = 0) u64 = {
  const size_ = match (attr) {
    case null => yield 0u64;
    case => yield 16u64;
  };
  log::printfln("landlock_create_ruleset with size={}", size_);
  return syscall(__NR_landlock_create_ruleset, attr: uintptr, size_, flags)!;
};

