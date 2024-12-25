// vim: set shiftwidth=2 :
//
// the "annotated logger" logs each incoming entry, prepended with additional
// information (such as the pid which triggered the log statement).
//
// TODO: pids logged here suffer from aliasing, when using PID namespaces;
// i could de-alias these by (either):
// 1. maintaining global state that is a sequence of pids, and appending to this
//    on each fork. e.g. `[pid=19332/2/4]`.
//    however siblings each placed in a new PID space will still have aliasing.
// 2. maintaining global state that is a sequence of pids, and appending to this
//    on each fork, by piping the fork'd PID from parent into child.
//    by using the parent's view, siblings are no longer aliased.

use fmt;
use log;
use rt;

export type logger = struct {
  // vtable (println, printfln)
  base: log::logger,
  // where to forward logs
  forward: nullable *log::logger,
};

let _global: logger = logger {
  base = log::logger {
    println = &log_println,
    printfln = &log_printfln,
  },
  forward = null,  // can't evaluate &log::default at compile time, so set null
};

// annotatedlogger with program lifetime, in case you don't want to manage that yourself
export const global: *logger = &_global;

export fn set_forward(me: *logger, forward: *log::logger) void = {
  me.forward = forward;
};

fn log_println(base: *log::logger, fields: fmt::formattable...) void = {
  // no way to nest `printf("[pid={}]: {}", getpid(), print(fields...))`
  // except by evaluating the inner printf:
  let entry = fmt::asprint(fields...);
  defer free(entry);
  log_println1(base, entry);
};
fn log_printfln(base: *log::logger, fmt: str, fields: fmt::field...) void = {
  // no way to nest `printf("[pid={}]: {}", getpid(), printf(fmt, fields...))`
  // except by evaluating the inner printf:
  let entry = fmt::asprintf(fmt, fields...);
  defer free(entry);
  log_println1(base, entry);
};
fn log_println1(base: *log::logger, entry: str) void = {
  let me = base: *logger;
  log::lprintfln(get_forward(me), "[pid={}] {}", rt::getpid(): int, entry);
};

fn get_forward(me: *logger) *log::logger = {
  return match (me.forward) {
    case null => yield log::default;
    case let l: *log::logger => yield l;
  };
};
