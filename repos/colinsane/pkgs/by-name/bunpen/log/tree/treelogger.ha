// vim: set shiftwidth=2 :
//
// the "tree logger" ("hierarchical logger") allows selective display of log messages.
// it works by deriving a "depth" from each log statement, similar in notion to
// a log level, and then only forwarding log statements less than some depth.
//
// the "depth" is derived from the format string in `printfln`.
// typical fmts are like:
// - `printfln("message from root: {}", ...)`: has depth=0
// - `printfln("[module] says {}", ...)`: has depth=1
// - `printfln("[module/child] says {}", ...)`: has depth=2
// - `printfln("[module/child/grandchild] says {}", ...)`: has depth=3

use fmt;
use log;
use strings;

export type logger = struct {
  // vtable (println, printfln)
  base: log::logger,
  // where to forward those logs which pass the filter
  forward: nullable *log::logger,
  // 0 = log nothing
  // 1 = log "toplevel" items (depth 1)
  // 2 = log items of depth 1 or 2
  // ...
  level: uint,
};

let _global: logger = logger {
  base = log::logger {
    println = &log_println,
    printfln = &log_printfln,
  },
  forward = null,  // can't evaluate &log::default at compile time, so set null
  level = 0,
};

// treelogger with program lifetime, in case you don't want to manage that yourself
export const global: *logger = &_global;

// alias for `log::setlogger`, so that caller doesn't have to do manual casting
export fn install(me: *logger) void = {
  log::setlogger(me: *log::logger);
};

export fn set_level(me: *logger, level: uint) void = {
  me.level = level;
};

export fn set_forward(me: *logger, forward: *log::logger) void = {
  me.forward = forward;
};

fn log_println(base: *log::logger, fields: fmt::formattable...) void = {
  let me = base: *logger;
  if (me.level > 0 && (len(fields) == 0 || get_depth(fields[0]) < me.level)) {
    log::lprintln(get_forward(me), fields...);
  };
};
fn log_printfln(base: *log::logger, fmt: str, fields: fmt::field...) void = {
  let me = base: *logger;
  if (me.level != 0 && get_depth(fmt) < me.level)
    log::lprintfln(get_forward(me), fmt, fields...);
};

fn get_forward(me: *logger) *log::logger = {
  return match (me.forward) {
    case null => yield log::default;
    case let l: *log::logger => yield l;
  };
};

fn get_depth(label: fmt::formattable) uint = {
  let label = match (label) {
    case let l: str => yield l;
    case => return 0;  // nothing other than a string could reasonable hold a label
  };
  if (!strings::hasprefix(label, '['))
    return 0;  // no context

  let depth: uint = 1;
  let iter = strings::iter(label);
  for (let c => strings::next(&iter)) {
    if (c == ']')
      break;
    if (c == '/')
      depth += 1;
  };

  return depth;
};
