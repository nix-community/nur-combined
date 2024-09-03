// vim: set shiftwidth=2 :
use path;
use rt;
use types::c;

export fn pivot_root(new_root: str, put_old: str) (rt::errno | void) = {
  let new_root_buf: [path::MAX]c::char = [0...];
  let put_old_buf: [path::MAX]c::char = [0...];
  return syscall_0_on_success(
    rt::SYS_pivot_root,
    make_cstr(&new_root_buf, new_root): uintptr: u64,
    make_cstr(&put_old_buf, put_old): uintptr: u64,
  );
};

