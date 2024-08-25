// vim: set shiftwidth=2 :
use path;
use rt;
use types::c;

export const MS_RDONLY: u64 = 1;
export const MS_NOSUID: u64 = 2;
export const MS_NODEV: u64 = 4;
export const MS_NOEXEC: u64 = 8;
export const MS_SYNCHRONOUS: u64 = 16;
export const MS_REMOUNT: u64 = 32;
export const MS_MANDLOCK: u64 = 64;
export const MS_DIRSYNC: u64 = 128;
export const MS_NOSYMFOLLOW: u64 = 256;
export const MS_NOATIME: u64 = 1024;
export const MS_NODIRATIME: u64 = 2048;
export const MS_BIND: u64 = 4096;
export const MS_MOVE: u64 = 8192;
export const MS_REC: u64 = 16384;
export const MS_VERBOSE: u64 = 32768;
export const MS_SILENT: u64 = 32768;
export const MS_POSIXACL: u64 = (1<<16);
export const MS_UNBINDABLE: u64 = (1<<17);
export const MS_PRIVATE: u64 = (1<<18);
export const MS_SLAVE: u64 = (1<<19);
export const MS_SHARED: u64 = (1<<20);
export const MS_RELATIME: u64 = (1<<21);
export const MS_KERNMOUNT: u64 = (1<<22);
export const MS_I_VERSION: u64 = (1<<23);
export const MS_STRICTATIME: u64 = (1<<24);
export const MS_LAZYTIME: u64 = (1<<25);

// XXX: hare is weird about these, and declares the flags parameter to `mount2`
// as `int` instead of `u64`.
// attempt to forcibily umount
export const MNT_FORCE: int = 0x00000001;
// just detach from the tree
export const MNT_DETACH: int = 0x00000002;
// mark for expiry
export const MNT_EXPIRE: int = 0x00000004;
// don't follow symlink on umount
export const UMOUNT_NOFOLLOW: int = 0x00000008;
// // flag guaranteed to be unused
// export const UMOUNT_UNUSED: int = 0x80000000;


// old magic mount flag (as in: no longer necessary, does nothing!)
export const MS_MGC_VAL: u64 = 0xC0ED0000;
// old magic mount mask (as in: no longer necessary, does nothing!)
export const MS_MGC_MSK: u64 = 0xffff0000;

// XXX(2024-08-24): hare stdlib `mount` syscall has a bug where it mounts
// `target` to `target`, not `source` to `target`.
// TODO: fix upstream
export fn mount(source: str, target: str, fstype: str, mountflags: u64, data: nullable *opaque) (rt::errno | void) = {
  let source_buf: [path::MAX]c::char = [0...];
  let target_buf: [path::MAX]c::char = [0...];
  let fstype_buf: [256]c::char = [0...];
  syscall(
    rt::SYS_mount,
    make_cstr(&source_buf, source): uintptr: u64,
    make_cstr(&target_buf, target): uintptr: u64,
    make_cstr(&fstype_buf, fstype): uintptr: u64,
    mountflags,
    data: uintptr,
  )?;
};
