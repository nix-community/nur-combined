// vim: set shiftwidth=2 :

use errors;
use errors::ext;
use log;
use os;
use os::exec;
use path;
use rt;
use strings;
use types::c;

export fn execve(path: str, argv: []str, envp: []str = []) rt::errno = {
  let path_buf: [path::MAX]c::char = [0...];

  syscall(
    rt::SYS_execve,
    make_cstr(&path_buf, path): uintptr: u64,
    // XXX: this "leaks" the c arrays, but not much can be done about that
    to_cstr_array(argv): *[*]nullable *const c::char: uintptr: u64,
    to_cstr_array(envp): *[*]nullable *const c::char: uintptr: u64,
  )?;

  log::fatal("[exec] unexpectedly returned without error");
};

// if `name` contains a slash, proceed as per `execve`.
// otherwise, crawl $PATH and try executing until we succeed.
export fn execvpe(name: str, argv: []str, envp: []str = []) rt::errno = {
  return if (strings::contains(name, "/")) {
    yield execve(name, argv, envp);
  } else {
    yield match (os::getenv("PATH")) {
      case let p: str => yield _execvpe(p, name, argv, envp);
      case void => yield execve(name, argv, envp);
    };
  };
};

// try `execvpe(name, argv, envp)`,
// but if it fails to find `name` on PATH, then `execve(default, argv, envp)`
export fn execvpe_or_default(default: str, name: str, argv: []str, envp: []str = []) rt::errno = {
  let rc = execvpe(name, argv, envp);
  return switch (rc) {
    case rt::ENOENT => yield execve(default, argv, envp);
    case => yield rc;
  };
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

// split `path` on `:`, crawl it, and try executing until we succeed.
// note that 1:1 parity with libc's execvpe is probably not what we have here.
//
// returns ENOENT if unable to locate the command on PATH
fn _execvpe(path: str, name: str, argv: []str, envp: []str = []) rt::errno = {
  let status = rt::ENOENT;
  let pieces = strings::split(path, ":");
  defer free(pieces);
  for (let p .. pieces) {
    let this_path = strings::join("/", p, name);
    defer free(this_path);
    status = execve(this_path, argv, envp);
    // try the next item, or return the status if this is the last one.
  };

  return status;
};
