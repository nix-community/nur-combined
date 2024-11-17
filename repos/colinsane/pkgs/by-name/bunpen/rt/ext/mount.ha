// vim: set shiftwidth=2 :
use path;
use rt;
use types::c;

// for use with `mount` syscall.
export type mount_flag = enum u64 {
  RDONLY = 1,
  NOSUID = 2,
  NODEV = 4,
  NOEXEC = 8,
  SYNCHRONOUS = 16,
  REMOUNT = 32,
  MANDLOCK = 64,
  DIRSYNC = 128,
  NOSYMFOLLOW = 256,
  NOATIME = 1024,
  NODIRATIME = 2048,
  BIND = 4096,
  MOVE = 8192,
  REC = 16384,
  VERBOSE = 32768,
  SILENT = 32768,
  POSIXACL = 1<<16,
  UNBINDABLE = 1<<17,
  PRIVATE = 1<<18,
  SLAVE = 1<<19,
  SHARED = 1<<20,
  RELATIME = 1<<21,
  KERNMOUNT = 1<<22,
  I_VERSION = 1<<23,
  STRICTATIME = 1<<24,
  LAZYTIME = 1<<25,
};
// union of `mount_flag`
export type mount_flags = u64;

// XXX: hare is weird about these, and declares the flags parameter to `mount2`
// as `int` instead of `u64`.
export type umount_flag = enum int {
  // attempt to forcibily umount
  MNT_FORCE = 0x00000001,
  // just detach from the tree
  MNT_DETACH = 0x00000002,
  // mark for expiry
  MNT_EXPIRE = 0x00000004,
  // don't follow symlink on umount
  UMOUNT_NOFOLLOW = 0x00000008,
  // // flag guaranteed to be unused
  // UMOUNT_UNUSED = 0x80000000,
};
// union of `umount_flag`
export type umount_flags = int;


// XXX(2024-08-24): hare stdlib `mount` syscall has a bug where it mounts
// `target` to `target`, not `source` to `target`.
// TODO: fix upstream
export fn mount(source: str, target: str, fstype: str, mountflags: mount_flags, data: (str | nullable *opaque)) (rt::errno | void) = {
  let source_buf: [path::MAX]c::char = [0...];
  let target_buf: [path::MAX]c::char = [0...];
  let fstype_buf: [256]c::char = [0...];
  let data_buf: [4096]c::char = [0...];

  let c_data: nullable *opaque = match (data) {
    case let p: nullable *opaque => yield p;
    case let p: str => yield make_cstr(&data_buf, p): nullable *opaque;
  };
  return syscall_0_on_success(
    rt::SYS_mount,
    make_cstr(&source_buf, source): uintptr: u64,
    make_cstr(&target_buf, target): uintptr: u64,
    make_cstr(&fstype_buf, fstype): uintptr: u64,
    mountflags,
    c_data: uintptr,
  );
};
