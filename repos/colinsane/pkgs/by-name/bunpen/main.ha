// vim: set shiftwidth=2 :
use config;
use errors;
use errors::ext;
use log;
use log::tree;
use restrict;
use restrict::ns;
use rt;
use rt::ext;
use strings;
use os;
use os::exec;
use types::c;

fn do_exec(path: str, args: []str) (os::exec::error | void) = {
  {
    let joined = strings::join(" ", args...);
    defer free(joined);
    log::printfln("exec {} with argv: {}", path, joined);
  };

  errors::ext::check("exec", rt::ext::execvpe(path, args, os::getenvs()));

  // XXX: os::exec::exec offers no way to preserve argv0, but it does
  // work if you don't care about that:
};

fn prepare_env(req: config::cli_request) config::exec_params = {
  {
    let argv_str = strings::join(" ", os::args...);
    defer free(argv_str);
    log::printfln("invoked with: {}", argv_str);
  };

  // set no_new_privs early. this is a flag which prevents us from gaining privs
  // via SUID/SGID executables, which we never intend to do.
  errors::ext::check("no_new_privs", rt::ext::no_new_privs());
  restrict::ns::namespace_restrict(&req.resources);
  restrict::capability_restrict(&req.resources);
  // XXX: landlock prevents other sandboxers like `bwrap` from executing,
  // because it forbids all future `mount` syscalls. so don't landlock.
  // restrict::landlock_restrict(&req.resources);

  return req.exec_params;
};

export fn main() void = {
  // install my logger, but defaulted to no logging.
  log::tree::install(tree::global);

  let opts = match (config::parse_args(os::args[1..])) {
    case errors::invalid =>
      config::usage();
      os::exit(1);
    case let other: config::cli_opts => yield other;
  };

  // configure logging early if we know it won't get in the way of anything
  if (opts.disable == "")
    log::tree::set_level(tree::global, opts.debug);

  let exec_params = match (config::ingest_cli_opts(opts)) {
    case config::help =>
      config::usage();
      os::exit(0);
    case let p: config::exec_params => yield p;  // run without sandboxing (BUNPEN_DISABLE=1)
    case let req: config::cli_request =>
      log::tree::set_level(tree::global, opts.debug);

      yield prepare_env(req);
  };

  errors::ext::check("exec <user command>", do_exec(exec_params.bin, exec_params.args));
};
