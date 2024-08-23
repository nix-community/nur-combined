// vim: set shiftwidth=2 :
use rt;

///// kernel consts. TODO: extract these from kernel headers, somehow.
// landlock syscall numbers
const __NR_landlock_create_ruleset: u64 = 444;
const __NR_landlock_add_rule: u64 = 445;
const __NR_landlock_restrict_self: u64 = 446;
// ---- landlock API constants ----
export const LANDLOCK_CREATE_RULESET_VERSION = 1u64 << 0;
// landlock API: fs_access
export const LANDLOCK_ACCESS_FS_EXECUTE: u64 = 1u64 << 0;
export const LANDLOCK_ACCESS_FS_WRITE_FILE: u64 = 1u64 << 1;
export const LANDLOCK_ACCESS_FS_READ_FILE: u64 = 1u64 << 2;
export const LANDLOCK_ACCESS_FS_READ_DIR: u64 = 1u64 << 3;
export const LANDLOCK_ACCESS_FS_REMOVE_DIR: u64 = 1u64 << 4;
export const LANDLOCK_ACCESS_FS_REMOVE_FILE: u64 = 1u64 << 5;
export const LANDLOCK_ACCESS_FS_MAKE_CHAR: u64 = 1u64 << 6;
export const LANDLOCK_ACCESS_FS_MAKE_DIR: u64 = 1u64 << 7;
export const LANDLOCK_ACCESS_FS_MAKE_REG: u64 = 1u64 << 8;
export const LANDLOCK_ACCESS_FS_MAKE_SOCK: u64 = 1u64 << 9;
export const LANDLOCK_ACCESS_FS_MAKE_FIFO: u64 = 1u64 << 10;
export const LANDLOCK_ACCESS_FS_MAKE_BLOCK: u64 = 1u64 << 11;
export const LANDLOCK_ACCESS_FS_MAKE_SYM: u64 = 1u64 << 12;
export const LANDLOCK_ACCESS_FS_REFER: u64 = 1u64 << 13;
export const LANDLOCK_ACCESS_FS_TRUNCATE: u64 = 1u64 << 14;
export const LANDLOCK_ACCESS_FS_IOCTL_DEV: u64 = 1u64 << 15;
// landlock API: net_access
export const LANDLOCK_ACCESS_NET_BIND_TCP: u64 = 1u64 << 0;
export const LANDLOCK_ACCESS_NET_CONNECT_TCP: u64 = 1u64 << 1;
// landlock API: landlock_rule_type
const LANDLOCK_RULE_PATH_BENEATH: u64 = 1;
const LANDLOCK_RULE_NET_PORT: u64 = 2;

// lifted from <repo:kernel.org/linux:include/uapi/linux/landlock.h>
// argument to `sys_landlock_create_ruleset`.
// landlock ruleset definition.
export type landlock_ruleset_attr = struct {
  // bitmask of handled filesystem actions
  handled_access_fs: u64,
  // bitmask of handled network actions
  handled_access_net: u64,
};
export type landlock_path_beneath_attr = struct {
  allowed_access: u64,
  parent_fd: i32,
};
export type landlock_net_port_attr = struct {
  allowed_access: u64,
  port: u64,
};

// landlock_create_ruleset syscall
export fn landlock_create_ruleset(attr: nullable *landlock_ruleset_attr, flags: u64 = 0) (rt::errno | u64) = {
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
) (rt::errno | u64) = {
  const (rule_type, rule_attr) = match (rule_attr) {
    case let p: *landlock_path_beneath_attr => yield (LANDLOCK_RULE_PATH_BENEATH, p: uintptr);
    case let p: *landlock_net_port_attr => yield (LANDLOCK_RULE_NET_PORT, p: uintptr);
  };
  return syscall(__NR_landlock_add_rule, ruleset_fd: u64, rule_type, rule_attr: uintptr, flags);
};

export fn landlock_restrict_self(
  ruleset_fd: u64,
  flags: u64 = 0,
) (rt::errno | u64) = {
  return syscall(__NR_landlock_restrict_self, ruleset_fd: u64, flags);
};
