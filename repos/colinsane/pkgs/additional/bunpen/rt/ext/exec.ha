// vim: set shiftwidth=2 :

use path;
use rt;
use types::c;

export fn execve(path: str, argv: []str, envp: []str = []) (rt::errno | void) = {
  let path_buf: [path::MAX]c::char = [0...];

  syscall(
    rt::SYS_execve,
    make_cstr(&path_buf, path): uintptr: u64,
    // XXX: this "leaks" the c arrays, but not much can be done about that
    to_cstr_array(argv): *[*]nullable *const c::char: uintptr: u64,
    to_cstr_array(envp): *[*]nullable *const c::char: uintptr: u64,
  )?;
};

// allocate and return a NULL-terminated array of pointers to c strings.
// caller is responsible for free'ing the resulting array AND its strings.
fn to_cstr_array(strs: []str) []nullable *const c::char = {
  let cstrs: []nullable *const c::char = alloc([], len(strs) + 1z);
  for (let s .. strs) {
    append(cstrs, c::fromstr(s));
  };
  append(cstrs, null);
  return cstrs;
};
