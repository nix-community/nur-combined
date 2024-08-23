// vim: set shiftwidth=2 :
use rt;

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

