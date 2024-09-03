// vim: set shiftwidth=2 :
use rt;

///// kernel consts. TODO: extract these from kernel headers, somehow.
// landlock syscall numbers
const __NR_landlock_create_ruleset: u64 = 444;
const __NR_landlock_add_rule: u64 = 445;
const __NR_landlock_restrict_self: u64 = 446;

// ---- landlock API constants ----
export type landlock_create_ruleset_flag = enum u64 {
  VERSION = 1 << 0,
};
// union of `landlock_create_ruleset_flag` values; could be 0.
export type landlock_create_ruleset_flags = u64;
// landlock API: fs_access
export type landlock_access_fs = enum u64 {
  EXECUTE = 1 << 0,
  WRITE_FILE = 1 << 1,
  READ_FILE = 1 << 2,
  READ_DIR = 1 << 3,
  REMOVE_DIR = 1 << 4,
  REMOVE_FILE = 1 << 5,
  MAKE_CHAR = 1 << 6,
  MAKE_DIR = 1 << 7,
  MAKE_REG = 1 << 8,
  MAKE_SOCK = 1 << 9,
  MAKE_FIFO = 1 << 10,
  MAKE_BLOCK = 1 << 11,
  MAKE_SYM = 1 << 12,
  REFER = 1 << 13,
  TRUNCATE = 1 << 14,
  IOCTL_DEV = 1 << 15,
};
// union of `landlock_access_fs` values; could be 0.
export type landlock_access_fs_set = u64;
// landlock API: net_access
export type landlock_access_net = enum u64 {
  BIND_TCP = 1 << 0,
  CONNECT_TCP = 1 << 1,
};
// union of `landlock_access_net` values; could be 0.
export type landlock_access_net_set = u64;
// landlock API: landlock_rule_type
type landlock_rule_type = enum u64 {
  PATH_BENEATH = 1,
  NET_PORT = 2,
};

// lifted from <repo:kernel.org/linux:include/uapi/linux/landlock.h>
// argument to `sys_landlock_create_ruleset`.
// landlock ruleset definition.
export type landlock_ruleset_attr = struct {
  // bitmask of handled filesystem actions
  handled_access_fs: landlock_access_fs_set,
  // bitmask of handled network actions
  handled_access_net: landlock_access_net_set,
};
export type landlock_path_beneath_attr = struct {
  allowed_access: landlock_access_fs_set,
  parent_fd: i32,
};
export type landlock_net_port_attr = struct {
  allowed_access: landlock_access_net_set,
  port: u64,
};

// landlock_create_ruleset syscall
export fn landlock_create_ruleset(attr: nullable *landlock_ruleset_attr, flags: landlock_create_ruleset_flags = 0) (rt::errno | u64) = {
  const size_: u64 = match (attr) {
    case null => yield 0;
    case => yield size(landlock_ruleset_attr);
  };
  return syscall(__NR_landlock_create_ruleset, attr: uintptr, size_, flags);
};

export fn landlock_add_rule(
  ruleset_fd: u64,
  rule_attr: (*landlock_path_beneath_attr | *landlock_net_port_attr),
  flags: u64 = 0,
) (rt::errno | void) = {
  const (rule_type, rule_attr) = match (rule_attr) {
    case let p: *landlock_path_beneath_attr => yield (landlock_rule_type::PATH_BENEATH, p: uintptr);
    case let p: *landlock_net_port_attr => yield (landlock_rule_type::NET_PORT, p: uintptr);
  };
  return syscall_0_on_success(__NR_landlock_add_rule, ruleset_fd: u64, rule_type, rule_attr: uintptr, flags);
};

export fn landlock_restrict_self(
  ruleset_fd: u64,
  flags: u64 = 0,
) (rt::errno | void) = {
  return syscall_0_on_success(__NR_landlock_restrict_self, ruleset_fd: u64, flags);
};
