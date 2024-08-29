// vim: set shiftwidth=2 :
use config;
use log;
use log::tree;
use restrict;
use rt;
use rtext;
use strings;
use os;
use os::exec;
use types::c;

fn do_exec(path: str, args: []str) (os::exec::error | void) = {
  {
    let joined = strings::join(" ", args...);
    defer free(joined);
    log::printfln("exec ({}): {}", path, joined);
  };

  rtext::check_error("exec", rtext::execve(path, args, os::getenvs()));

  // XXX: os::exec::exec offers no way to preserve argv0, but it does
  // work if you don't care about that:
};

export fn main() void = {
  // install my logger, but defaulted to no logging.
  log::tree::install(tree::global);

  let name = os::args[0];
  let opts = match (config::parse_args(os::args[1..])) {
    case config::error =>
      config::usage();
      os::exit(1);
    case let other: config::cli_opts => yield other;
  };

  // configure logging early
  log::tree::set_level(tree::global, opts.debug);

  let req = match (config::ingest_cli_opts(opts)) {
    case config::help =>
      config::usage();
      os::exit(0);
    case let other: config::cli_request => yield other;
  };

  let what = restrict::resources {
    paths = req.paths,
    net = req.keep_net,
  };

  rtext::no_new_privs()!;
  restrict::namespace_restrict(&what);
  restrict::landlock_restrict(&what);
  rtext::check_error("exec <user command>", do_exec(req.exec_bin, req.exec_args));
};
