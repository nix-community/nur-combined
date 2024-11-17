// vim: set shiftwidth=2 :
use rt;

// for use with `setns`, `unshare`, `clone` syscalls
export type clone_flag = enum u64 {
  // new time namespace. calling process is NOT moved into the namespace.
  NEWTIME = 0x00000080,

  // new mount namespace.
  // NEWNS implies FS.
  NEWNS = 0x00020000,

  NEWCGROUP = 0x02000000,

  // new utsname namespace
  NEWUTS = 0x04000000,

  // NEWIPC implies SYSVSEM.
  NEWIPC = 0x08000000,

  // NEWUSER implies THREAD and FS.
  // calling process must NOT be multi-threaded.
  NEWUSER = 0x10000000,

  // new process ID namespace. calling process is NOT moved into the namespace.
  // the first new child spawned becomes pid 1 and has the role of init(1).
  // NEWPID implies THREAD.
  NEWPID = 0x20000000,

  NEWNET = 0x40000000,

  // additional CLONE flags in kernel, omitted until i need them.
};
// union of `clone_flag`
export type clone_flags = u64;

// export fn setns(ns_fd: i32, nstype: i32) (rt::errno | u64) = {
//   return syscall(rt::SYS_setns, ns_fd: u64, nstype: u64);
// };

export fn unshare(flags: clone_flags) (void | rt::errno) = {
  return syscall_0_on_success(rt::SYS_unshare, flags);
};
