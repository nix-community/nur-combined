// vim: set shiftwidth=2 :
use config;
use errors;
use errors::ext;
use log;
use log::annotated;
use log::tree;
use resources;
use restrict;
use restrict::ns;
use rt;
use rt::ext;
use strings;
use os;
use os::exec;
use types::c;

fn do_exec(path: str, argv: []str, extra_env: []str) (void | rt::errno) = {
  {
    let argv_joined = strings::join(" ", argv...)!;
    defer free(argv_joined);

    let extra_env_joined = strings::join(" ", extra_env...)!;
    defer free(extra_env_joined);

    log::printfln("exec {} with argv: {}, extra_env: {}", path, argv_joined, extra_env_joined);
  };

  let env = merge_env(os::getenvs(), extra_env);

  return rt::ext::execvpe(path, argv, env);

  // XXX: os::exec::exec offers no way to preserve argv0, but it does
  // work if you don't care about that:
};

fn merge_env(base: []str, overrides: []str) []str = {
  let merged: []str = [];

  // /proc/self/environ is actually just a sequence of null-terminated strings,
  // like `VAR_A=VALUE_A\0VAR_B=VALUE_B\0...`.
  //
  // we aim to keep the environ maximally undisturbed (i.e. preserve ordering and
  // duplicates unless there's a good reason not to).
  //
  // wherever the user explicitly overrides an env var (i.e. `--bunpen-env
  // K=V`), we:
  // 1. remove ALL assignments to that variable from the base environment.
  // 2. append a new assignment to the environment.
  for (let old .. base) {
    let (old_key, _old_value) = strings::cut(old, "=");
    let keep_old = true;
    for (let new .. overrides) {
      let (new_key, _new_value) = strings::cut(new, "=");
      if (old_key == new_key)
        keep_old = false;
    };
    if (keep_old)
      append(merged, old)!;
  };

  for (let new .. overrides)
    append(merged, new)!;

  return merged;
};

fn log_diagnostics() void = {
  let argv_str = strings::join(" ", os::args...)!;
  defer free(argv_str);
  log::printfln("invoked with: {}", argv_str);
};

fn restrict_self(res: *resources::resources) void = {
  // set no_new_privs early. this is a flag which prevents us from gaining privs
  // via SUID/SGID executables, which we never intend to do.
  errors::ext::check("no_new_privs", rt::ext::no_new_privs());
  restrict::restrict(res);
  // XXX: landlock prevents other sandboxers like `bwrap` from executing,
  // because it forbids all future `mount` syscalls. so don't landlock.
  // restrict::landlock_restrict(res);
};

export fn main() void = {
  // install my logger, but defaulted to no logging.
  log::tree::set_forward(tree::global, log::annotated::global);
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
    case let p: config::exec_params =>
      // run without sandboxing (BUNPEN_DISABLE=1)
      yield config::exec_params {
        bin = p.bin,
        args = p.args,
        // don't modify the environment when not sandboxed
        extra_env = [],
      };
    case let req: config::cli_request =>
      log::tree::set_level(tree::global, opts.debug);
      log_diagnostics();
      restrict_self(&req.resources);
      yield req.exec_params;
  };

  errors::ext::check("exec <user command>", do_exec(exec_params.bin, exec_params.args, exec_params.extra_env));
};
