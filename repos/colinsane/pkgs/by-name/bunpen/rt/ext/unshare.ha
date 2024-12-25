// vim: set shiftwidth=2 :
use rt;

// hare defines this for riscv and aarch64, but not x86
// const __NR_pidfd_open: u64 = 434;

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

export fn unshare(flags: clone_flags) (void | rt::errno) = {
  return syscall_0_on_success(rt::SYS_unshare, flags);
};

// // ns_fd can come from `open("/proc/$PID/ns/<ns>")` OR
// // `pidfd_open(PID, flags)`
// export fn setns(ns_fd: u64, nstype: clone_flags) (rt::errno | void) = {
//   return syscall_0_on_success(rt::SYS_setns, ns_fd: u64, nstype: u64);
// };
//
// // return a file descriptor that represents the PID namespace of the given process.
// // this can be used with `setns`.
// // the CLOSE_ON_EXEC flag is implicitly set.
// export fn pidfd_open(pid: rt::pid_t, flags: u64 = 0) (rt::errno | u64) = {
//   return syscall(__NR_pidfd_open, pid: u64, flags);
// };
