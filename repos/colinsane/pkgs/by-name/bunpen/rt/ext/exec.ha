// vim: set shiftwidth=2 :

use errors::ext;
use fmt;
use log;
use os;
use path;
use rt;
use strings;
use types::c;

fn log_pre_exec(path: str, argv: []str, envp: []str = []) (void | nomem) = {
  let logv: []fmt::formattable = [];
  defer free(logv);
  append(logv, "[exec] execve:")?;

  if (len(argv) != 0 && argv[0] != path)
    append(logv, fmt::asprintf("--argv0={}", argv[0])?)?;

  for (let env .. envp)
    append(logv, env)?;

  append(logv, path)?;
  for (let i = 1z; i < len(argv); i += 1)
    append(logv, argv[i])?;
  log::println(logv...);
};

export fn execve(path: str, argv: []str, envp: []str = []) rt::errno = {
  let path_buf: [path::MAX]c::char = [0...];

  errors::ext::check("[exec] log_pre_exec", log_pre_exec(path, argv, envp));

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
fn try_to_cstr_array(strs: []str) ([]nullable *const c::char | nomem) = {
  let cstrs: []nullable *const c::char = alloc([], len(strs) + 1z)?;
  for (let s .. strs) {
    append(cstrs, c::fromstr(s)?)?;
  };
  append(cstrs, null)?;
  return cstrs;
};

fn to_cstr_array(strs: []str) []nullable *const c::char = {
  return match (try_to_cstr_array(strs)) {
    case let a: []nullable *const c::char => yield a;
    case nomem => errors::ext::fatal("[exec] to_cstr_array", nomem);
  };
};

// split `path` on `:`, crawl it, and try executing until we succeed.
// note that 1:1 parity with libc's execvpe is probably not what we have here.
//
// returns ENOENT if unable to locate the command on PATH
fn _execvpe(path: str, name: str, argv: []str, envp: []str = []) rt::errno = {
  let status = rt::ENOENT;
  let pieces = errors::ext::check_str_arr("[exec] strings::split", strings::split(path, ":"));
  defer free(pieces);
  for (let p .. pieces) {
    let this_path = errors::ext::check_str("[exec] strings::join", strings::join("/", p, name));
    defer free(this_path);
    status = execve(this_path, argv, envp);
    // try the next item, or return the status if this is the last one.
  };

  return status;
};
