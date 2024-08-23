// vim: set shiftwidth=2 :
use config;
use log;
use restrict;
use rtext;
use strings;
use os;
use os::exec;

fn do_exec(args: []str) never = {
  let joined = strings::join(" ", args...);
  log::printfln("exec: {}", joined);
  free(joined);

  let cmd = os::exec::cmd(args[0], args[1..]...)!;
  os::exec::exec(&cmd);
};

export fn main() void = {
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

  rtext::no_new_privs();
  restrict::landlock_restrict(&what);
  if (opts.drop_shell) {
    do_exec(["/bin/sh"]);
  } else {
    do_exec(opts.cmd);
  };
};
