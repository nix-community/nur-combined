// vim: set shiftwidth=2 :
// ingest literal `cli_opts` into a more computer-friendly form

use errors;
use errors::ext;
use fs;
use log;
use os;
use path;
use regex;
use resources;
use rt;
use rt::ext;
use strings;

// the user requested to see help.
export type help = void;

export type cli_request = struct {
  exec_params: exec_params,
  // what to keep in the restricted environment (paths, network, etc)
  resources: resources::resources,
};

export type exec_params = struct {
  // args to invoke the binary with.
  // `args[0]` is, by convention, the name of the executable,
  // relevant for multi-call binaries like `busybox`.
  args: []str,
  // *complete* environment with which to execute the binary
  env: []str,
  // path to the binary to be exec'd inside the sandbox.
  // if the user requested `--bunpen-drop-shell`, this will be their shell (e.g. /bin/sh), assuming `BUNPEN_DISABLE=1` wasn't specified.
  bin: str,
};

type env = struct {
  home: str,
  pwd: str,
  xdg_runtime_dir: str,
};

fn cli_opts_get_exec_params(opts: cli_opts, env: env) exec_params = {
  let params = exec_params { ... };

  //---- ingest `cmd` ----//
  if (len(os::args) > 0) {
    // forward argv0
    if ((os::args[0] == "bunpen" || strings::hassuffix(os::args[0], "/bunpen")) && len(opts.cmd) > 0) {
      log::println("[config] using binary path as argv[0]");
      append(params.args, opts.cmd[0]);
    } else {
      log::println("[config] forwarding argv[0]");
      append(params.args, os::args[0]);
    };
  };

  let saw_bin_path = false;
  for (let arg .. opts.cmd) {
    if (saw_bin_path) {
      append(params.args, arg);
    } else {
      params.bin = arg;
      saw_bin_path = true;
    };
  };

  //---- ingest `env` ----//

  for (let old .. os::getenvs()) {
    let (old_key, _old_value) = strings::cut(old, "=");
    let keep_old = true;
    for (let new .. opts.env) {
      let (new_key, _new_value) = strings::cut(new, "=");
      if (old_key == new_key) {
        keep_old = false;
      };
    };
    if (keep_old) {
      append(params.env, old);
    };
  };
  for (let new .. opts.env) {
    let substituted = env_subst(env, new);
    append(params.env, substituted);
  };

  return params;
};

export fn ingest_cli_opts(opts: cli_opts) (cli_request | exec_params | help) = {
  //---- ingest `help` ----//
  if (opts.help) {
    return help;
  };

  let env = env_new();
  let req = cli_request {
    resources = resources::resources { net = resources::net_none, dbus = void, ... },
    ...
  };

  //---- ingest opts.cmd ----//
  req.exec_params = cli_opts_get_exec_params(opts, env);

  //---- ingest `disable` ----//
  if (does_option_apply_to_self(opts.disable, &req.exec_params))
      return req.exec_params;

  //---- ingest `caps` ----//
  req.resources.caps = resources::cap_array_to_caps(opts.keep_caps);

  //---- ingest `keep_all_caps` ----//
  if (opts.keep_all_caps)
    req.resources.caps = rt::ext::CAPS_ALL;

  //---- ingest `dbus_call` ----//
  let any_dbus = false;
  let dbus_subset = resources::dbus_subset { ... };
  for (let i .. opts.dbus_call) {
    any_dbus = true;
    append(dbus_subset.call, i);
  };

  //---- ingest `dbus_own` ----//
  for (let i .. opts.dbus_own) {
    any_dbus = true;
    append(dbus_subset.own, i);
  };

  if (any_dbus)
    req.resources.dbus = dbus_subset;

  //---- ingest `keep_ipc` ----//
  req.resources.ipc = opts.keep_ipc;

  //---- ingest `net_dev`, `net_gateway`, `dns` ----//
  let net_subset = resources::net_subset {
    dev = opts.net_dev,
    dns = opts.dns,
    gateway = opts.net_gateway,
  };

  if (net_subset.dev != "" && net_subset.dns != "" && net_subset.gateway != "")
    req.resources.net = net_subset;

  //---- ingest `keep_net` ----//
  if (opts.keep_net)
    req.resources.net = resources::net_all;

  //---- ingest `keep_pid` ----//
  req.resources.pid = opts.keep_pid;

  //---- ingest `paths` ----//
  ingest_paths(&req.resources.paths, opts.paths, env);

  //---- ingest `try_keep_users` ----//
  req.resources.try_users = opts.try_keep_users;

  //---- ingest `autodetect` (must be done after exec_params) ----//
  match (opts.autodetect) {
    case let method: autodetect =>
      // N.B.: skip first arg, since that's the name of the executable and
      // surely not an argument
      ingest_paths(&req.resources.paths, req.exec_params.args[1..], env, method);
    case void => void;
  };

  //---- ingest `drop_shell` (must be done after autodetect) ----//
  if (does_option_apply_to_self(opts.drop_shell, &req.exec_params)) {
    // ignore the original command, and overwrite it with an interactive shell.
    // TODO: respect the user's `$SHELL`.
    req.exec_params.bin = "/bin/sh";
    delete(req.exec_params.args[..]);
    append(req.exec_params.args, "sh");
  };

  return req;
};

// consider a string like "", "0", "1", "all", "*", "sane-which", ...;
// return true if it either
// (1) looks truthy (1, all)
// (2) it looks to be referring to the current binary (*, sane-which)
fn does_option_apply_to_self(value: str, exec_params: *const exec_params) bool = {
  if (value == "")
    return false;  // prevent over-eager regex match

  if (value == "1" || value == "all" || value == "ALL" || value == "*")
    return true;

  match (regex::compile(value)) {
    case let re: regex::regex =>
      defer regex::finish(&re);
      if (regex::test(&re, exec_params.bin))
        return true;
      if (len(exec_params.args) > 0 && regex::test(&re, exec_params.args[0]))
        return true;
    case let e: regex::error =>
      log::printfln("[config] failed to parse option regex {}: {}", value, e);
  };

  return false;
};

// convert each item in `from` to a path, and append to `into`.
// non-absolute paths are interpreted as relative to `env.pwd`.
// a limited set of environment variables are expanded for each path; see `env_subst`.
// optional `autodetect` flag, to query each path on-disk and filter or map it
//   based on the desired environment.
//   in this mode, environment variables are *not* expanded.
fn ingest_paths(into: *[]path::buffer, from: []str, env: env, method: (void | autodetect) = void) void = {
  // enforce file mode requirements as per autodetect (if specified)
  let (do_env_subst, allow_nonexistent, allow_file, allow_dir, allow_parent) = match (method) {
    case void => yield (true, true, true, true, false);
    case let detect: autodetect => yield switch (detect) {
      case autodetect::EXISTING                 => yield (false, false, true, true, false);
      case autodetect::EXISTING_DIR             => yield (false, false, false, true, false);
      case autodetect::EXISTING_FILE            => yield (false, false, true, false, false);
      case autodetect::EXISTING_FILE_OR_PARENT  => yield (false, false, true, false, true);
      case autodetect::EXISTING_DIR_OR_PARENT   => yield (false, false, false, true, true);
      case autodetect::EXISTING_OR_PARENT       => yield (false, false, true, true, true);
      case autodetect::PARENT                   => yield (false, false, false, false, true);
    };
  };

  for (let path_str .. from) {
    if (do_env_subst) {
      path_str = env_subst(env, path_str);
    };
    errors::ext::swallow("[config/path] omitting path {}",
      try_as_path(into, path_str, env.pwd, allow_nonexistent, allow_file, allow_dir, allow_parent),
      path_str
    );
  };
};

// consider the `path_arg` in the context of the `allow_*` restrictions,
// and append either that path, its parent, or neither.
fn try_as_path(
  into: *[]path::buffer,
  path_arg: str,
  base: (str | void),
  allow_nonexistent: bool,
  allow_file: bool,
  allow_dir: bool,
  allow_parent: bool,
) (void | fs::error | path::error) = {
  let path_buf = if (path::abs(path_arg)) {
    yield path::init(path_arg)?;
  } else match (base) {
    case let b: str => yield path::init(b, path_arg)?;
    case void =>
      log::printfln("[config/path/try] path is relative, but to an unknown base {}", path_arg);
      return path::not_prefix;
  };

  // ensure the path has the right type; fallback to parent if requested.
  match (check_exists(&path_buf, allow_nonexistent, allow_file, allow_dir)) {
    case void => void;
    case let err: (fs::error | path::error) =>
      if (allow_parent) {
        path::push(&path_buf, "..")?;
        check_exists(&path_buf, false, false, true)?;
      } else
        return err;
  };

  append(into, path_buf);
};

// ensure that the specified path exists.
// if it exists but not as a directory, succeed only if `dir_ok = true`.
fn check_exists(pathbuf: *path::buffer, noexist_ok: bool, file_ok: bool, dir_ok: bool) (void | fs::error | path::error) = {
  if (noexist_ok)
    return void;
  if (!file_ok && !dir_ok)
    return errors::invalid;  // save a syscall for `--bunpen-autodetect parent`

  // stat the path. in case of symlinks dereference to the underlying entity.
  let dereferenced = fs::realpath(os::cwd, path::string(pathbuf))?;
  let stat = fs::stat(os::cwd, dereferenced)?;
  let is_dir = (stat.mode & rt::S_IFDIR) != 0;

  if (file_ok || (dir_ok && is_dir))
    return

  log::printfln("[config/path/try] not adding path (exists, but as wrong type): {}", path::string(pathbuf));
  return fs::wrongtype;
};

fn env_new() env = {
  return env {
    home = getenv_default("HOME"),
    pwd = os::getcwd(),
    xdg_runtime_dir = getenv_default("XDG_RUNTIME_DIR"),
  };
};

// return the value of the environment variable keyed by `key`, or "" if it
// doesn't exist
fn getenv_default(key: str) str = {
  return match (os::getenv(key)) {
    case void => yield "";
    case let value: str => yield value;
  };
};

fn env_subst(env: env, before: str) str = {
  return strings::multireplace(before, ("$$", "$"), ("$HOME", env.home), ("$XDG_RUNTIME_DIR", env.xdg_runtime_dir));
};
