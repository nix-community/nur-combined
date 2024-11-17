// vim: set shiftwidth=2 :
use errors;
use fmt;
use fs;
use io;
use log;
use os;
use os::exec;
use path;
use rt;

export type error = (errors::error | fs::error | io::error | os::exec::error | path::error | rt::errno);

// stringify an error. return value is statically allocated, no need to free.
export fn maybe_strerror(what: (void | ...error)) (void | str) = {
  let errorbuf: [4096]u8 = [0...];
  return match (what) {
    case let e: errors::error => yield errors::strerror(e);
    case let e: fs::error => yield fs::strerror(e);
    case let e: io::error => yield io::strerror(e);
    case let e: os::exec::error => yield os::exec::strerror(e);
    case let e: path::error => yield path::strerror(e);
    case let e: rt::errno =>
      // N.B.: this panics if the buffer is too small.
      yield fmt::bsprintf(errorbuf[..], "{}: {}", rt::errname(e), rt::strerror(e));
    case void => yield void;
  };
};

export fn strerror(what: error) str = {
  return match (maybe_strerror(what)) {
    case let s: str => yield s;
    case void => log::fatal("failed to format error");
  };
};

fn print_error_with_context(user_context: str, add_context: str, e: error, fmt_args: fmt::field...) void = {
  let context_buf: [4096]u8 = [0...];
  log::println(
    fmt::bsprintf(context_buf[..], user_context, fmt_args...),
    ":",
    strerror(e),
    add_context,
  );
};

fn nonfatal(context: str, e: error, fmt_args: fmt::field...) void = {
  print_error_with_context(context, "(nonfatal)", e, fmt_args...);
};

fn fatal(context: str, e: error, fmt_args: fmt::field...) never = {
  print_error_with_context(context, "(FATAL)", e, fmt_args...);
  os::exit(255);
};

export fn check(context: str, what: (void | ...error), fmt_args: fmt::field...) void = {
  return match (what) {
    case void => yield void;
    case let e: error => fatal(context, e, fmt_args...);
  };
};

export fn check_u64(context: str, what: (u64 | ...error), fmt_args: fmt::field...) u64 = {
  return match (what) {
    case let v: u64 => yield v;
    case let e: error => fatal(context, e, fmt_args...);
  };
};

export fn check_int(context: str, what: (int | ...error), fmt_args: fmt::field...) int = {
  return match (what) {
    case let v: int => yield v;
    case let e: error => fatal(context, e, fmt_args...);
  };
};

// on error => log the error and return false.
// on non-error => return true.
export fn swallow(context: str, what: (void | ...error), fmt_args: fmt::field...) bool = {
  return match (what) {
    case void => yield true;
    case let e: error =>
      nonfatal(context, e, fmt_args...);
      yield false;
  };
};
