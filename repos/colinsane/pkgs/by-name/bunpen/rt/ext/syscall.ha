// vim: set shiftwidth=2 :
use rt;

// like `rt::syscall`, but maps negative return values to `errno`
fn syscall(num: u64, args: u64...) (rt::errno | u64) = {
  return wrap_return(rt::syscall(num, args...));
};

// for a syscall which only success exclusively returns 0, convert any non-zero
// into an error. stricter version of `syscall`
fn syscall_0_on_success(num: u64, args: u64...) (rt::errno | void) = {
  let rc = rt::syscall(num, args...);
  if (rc != 0) {
    return (-(rc: i64)): rt::errno;
  };
};

// for a syscall which returns `int` instead of `u64` on success.
fn syscall_int_on_success(num: u64, args: u64...) (rt::errno | int) = {
  return match (syscall(num, args...)) {
    case let e: rt::errno => yield e;
    case let v: u64 => yield v: int;
  };
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

