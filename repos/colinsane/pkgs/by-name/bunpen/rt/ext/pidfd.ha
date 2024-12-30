// vim: set shiftwidth=2 :
use rt;

// hare defines these for riscv and aarch64, but not x86
const __NR_pidfd_open: u64 = 434;
const __NR_pidfd_getfd: u64 = 438;

// return a file descriptor that represents the PID namespace of the given process.
// this can be used with `setns`.
// the CLOSE_ON_EXEC flag is implicitly set.
// flags can be:
// - PIDFD_NONBLOCK
export fn pidfd_open(pid: rt::pid_t, flags: u64 = 0) (rt::errno | int) = {
  return syscall_int_on_success(__NR_pidfd_open, pid: u64, flags);
};

export fn pidfd_getfd(pidfd: int, targetfd: int, flags: u64 = 0) (rt::errno | int) = {
  return syscall_int_on_success(__NR_pidfd_getfd, pidfd: u64, targetfd: u64, flags);
};
