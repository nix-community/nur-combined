// vim: set shiftwidth=2 :
use config;
use log;
use restrict;
use rt;
use rtext;
use strings;
use os;
use os::exec;
use types::c;

fn do_exec(name: str, args: []str) (os::exec::error | void) = {
  {
    let joined = strings::join(" ", args...);
    defer free(joined);
    log::printfln("exec ({}): {}", name, joined);
  };

  let path = args[0];
  args[0] = name;
  rtext::check_error("exec", rtext::execve(path, args));

  // XXX: os::exec::exec offers no way to preserve argv0, but the following
  // works if you don't care about that:
  // let cmd = os::exec::cmd(args[0], args[1..]...)?;
  // os::exec::exec(&cmd);
};

export fn main() void = {
  let name = os::args[0];
  let opts = config::parse_args(os::args[1..]);

  if (opts.help) {
    config::usage();
    os::exit(0);
  };

  if (opts.debug) {
    log::setlogger(log::default);
  } else {
    log::setlogger(log::silent);
  };

  let what = restrict::resources {
    paths = opts.paths,
    net = opts.keep_net,
  };

  rtext::no_new_privs()!;
  restrict::namespace_restrict(&what);
  restrict::landlock_restrict(&what);
  if (opts.drop_shell) {
    // TODO: respect the user's $SHELL
    rtext::check_error("exec /bin/sh", do_exec("sh", ["/bin/sh"]));
  } else {
    rtext::check_error("exec <user command>", do_exec(name, opts.cmd));
  };
};
