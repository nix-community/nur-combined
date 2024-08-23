// vim: set shiftwidth=2 :
use rt;

fn no_new_privs() void = {
  rt::prctl(rt::PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0)!;
};

///// kernel consts. TODO: extract these from kernel headers, somehow.
// landlock syscall ID
const __NR_landlock_create_ruleset: u64 = 444;
const __NR_landlock_add_rule: u64 = 445;
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
// landlock API: landlock_rule_type
const LANDLOCK_RULE_PATH_BENEATH: u64 = 1;
const LANDLOCK_RULE_NET_PORT: u64 = 2;

// lifted from <repo:kernel.org/linux:include/uapi/linux/landlock.h>
// argument to `sys_landlock_create_ruleset`.
// landlock ruleset definition.
type landlock_ruleset_attr = struct {
  // bitmask of handled filesystem actions
  handled_access_fs: u64,
  // bitmask of handled network actions
  handled_access_net: u64,
};
type landlock_path_beneath_attr = struct {
  allowed_access: u64,
  parent_fd: i32,
};
type landlock_net_port_attr = struct {
  allowed_access: u64,
  port: u64,
};

// not defined in kernel. it just uses `*void` that could be any of the attrs;
// hare requires me to explicitly enumerate them
type landlock_rule_attr = union {
  path_beneath: landlock_path_beneath_attr,
  net_port: landlock_net_port_attr,
};


// landlock_create_ruleset syscall
fn landlock_create_ruleset(attr: nullable *landlock_ruleset_attr, flags: u64) u64 = {
  const size_: u64 = match (attr) {
    case null => yield 0;
    case => yield size(landlock_ruleset_attr);
  };
  return syscall(__NR_landlock_create_ruleset, attr: uintptr, size_, flags)!;
};

fn landlock_add_rule(
  ruleset_fd: i32,
  rule_type: u64,  //< landlock_rule_type
  rule_attr: *landlock_rule_attr,
  flags: u64,
) (rt::errno | u64) = {
  return syscall(__NR_landlock_add_rule, ruleset_fd: u64, rule_type, rule_attr: uintptr, flags);
};


// like `rt::syscall`, but maps negative return values to `errno`
fn syscall(num: u64, args: u64...) (rt::errno | u64) = {
  return wrap_return(rt::syscall(num, args...));
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
