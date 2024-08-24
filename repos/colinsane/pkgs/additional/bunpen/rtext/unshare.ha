// vim: set shiftwidth=2 :
use rt;

//// for use with `setns`, `unshare`, `clone` syscalls
// new time namespace. calling process is NOT moved into the namespace.
export const CLONE_NEWTIME: u64 = 0x00000080;

// new mount namespace.
// CLONE_NEWNS implies CLONE_FS.
export const CLONE_NEWNS: u64 = 0x00020000;

export const CLONE_NEWCGROUP: u64 = 0x02000000;

// new utsname namespace
export const CLONE_NEWUTS: u64 = 0x04000000;

// CLONE_NEWIPC implies CLONE_SYSVSEM.
export const CLONE_NEWIPC: u64 = 0x08000000;

// CLONE_NEWUSER implies CLONE_THREAD and CLONE_FS.
// calling process must NOT be multi-threaded.
export const CLONE_NEWUSER: u64 = 0x10000000;

// new process ID namespace. calling process is NOT moved into the namespace.
// the first new child spawned becomes pid 1 and has the role of init(1).
// CLONE_NEWPID implies CLONE_THREAD.
export const CLONE_NEWPID: u64 = 0x20000000;

export const CLONE_NEWNET: u64 = 0x40000000;

// additional CLONE flags in kernel, omitted until i need them.

// export fn setns(ns_fd: i32, nstype: i32) (rt::errno | u64) = {
//   return syscall(rt::SYS_setns, ns_fd: u64, nstype: u64);
// };

export fn unshare(flags: u64) (rt::errno | u64) = {
  return syscall(rt::SYS_unshare, flags);
};
