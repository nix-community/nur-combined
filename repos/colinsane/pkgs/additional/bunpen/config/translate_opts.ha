// vim: set shiftwidth=2 :
// ingest literal `cli_opts` into a more computer-friendly form

use fs;
use log;
use os;
use path;
use restrict;
use rt;
use rtext;

// the user requested to see help.
export type help = !void;

export type cli_request = struct {
  // args to invoke the binary with.
  // `exec_args[0]` is, by convention, the name of the executable,
  // relevant for multi-call binaries like `busybox`.
  exec_args: []str,
  // path to the binary to be exec'd inside the sandbox.
  // if the user requested `--bunpen-drop-shell`, this will be their shell (e.g. /bin/sh).
  exec_bin: str,
  // what to keep in the restricted environment (paths, network, etc)
  resources: restrict::resources,
};

export fn ingest_cli_opts(opts: cli_opts) (cli_request | help) = {
  let req = cli_request { ... };

  //---- ingest `cmd` ----//
  if (len(os::args) > 0) {
    // forward argv0
    append(req.exec_args, os::args[0]);
  };

  let saw_bin_path = false;
  for (let arg .. opts.cmd) {
    if (saw_bin_path) {
      append(req.exec_args, arg);
    } else {
      req.exec_bin = arg;
      saw_bin_path = true;
    };
  };

  //---- ingest `help` ----//
  if (opts.help) {
    return help;
  };

  //---- ingest `home_paths` ----//
  ingest_paths(&req.resources.paths, opts.home_paths, os::getenv("HOME"));

  //---- ingest `keep_net` ----//
  req.resources.net = opts.keep_net;

  //---- ingest `keep_pid` ----//
  req.resources.pid = opts.keep_pid;

  //---- ingest `paths` ----//
  ingest_paths(&req.resources.paths, opts.paths, os::getcwd(), true);

  //---- ingest `run_paths` ----//
  ingest_paths(&req.resources.paths, opts.run_paths, os::getenv("XDG_RUNTIME_DIR"));

  //---- ingest `autodetect` (must be done after exec_args) ----//
  match (opts.autodetect) {
    case let method: autodetect =>
      // N.B.: skip first arg, since that's the name of the executable and
      // surely not an argument
      ingest_autodetect(&req.resources.paths, req.exec_args[1..], method);
    case void => void;
  };

  //---- ingest `drop_shell` (must be done after autodetect) ----//
  if (opts.drop_shell) {
    // ignore the original command, and overwrite it with an interactive shell.
    // TODO: respect the user's `$SHELL`.
    req.exec_bin = "/bin/sh";
    delete(req.exec_args[..]);
    append(req.exec_args, "sh");
  };

  return req;
};

// convert each item in `from` to a path, relative to `base`, and append to `into`.
// if `allow_abs`, then paths with start with `/` are treated as absolute,
// instead of as relative to `base`.
fn ingest_paths(into: *[]path::buffer, from: []str, base: (str | void), allow_abs: bool = false) void = {
  for (let path_str .. from) {
    match (get_path(path_str, base, allow_abs)) {
      case let p: path::buffer => append(into, p);
      case let e: path::error =>
        log::printfln("[config] omitting path {}: {}", path_str, path::strerror(e));
      case let e: missing_base =>
        log::printfln("[config] omitting path {}: {}", translate_strerror(e));
    };
  };
};

// path was specified in relative form, but the directory to base that on was omitted.
type missing_base = !void;
// `ingest_paths` helper: transforms `path_str` into an absolute path.
fn get_path(path_str: str, base: (str | void), allow_abs: bool) (path::buffer | path::error | missing_base) = {
  if (allow_abs && path::abs(path_str)) {
    return path::init(path_str)?;
  } else match (base) {
    case let b: str => return path::init(b, path_str)?;
    case void => return missing_base;
  };
};

// processes arguments from `consider` in the context of `--bunpen-autodetect METHOD`,
// and appends any extra paths wanted in the sandbox to `into` in response.
fn ingest_autodetect(into: *[]path::buffer, consider: []str, method: autodetect) void = {
  let base = os::getcwd();
  for (let path_str .. consider) {
    match (get_path(path_str, base, true)) {
      case let p: path::buffer => try_as_path(into, p, method);
      case let e: path::error =>
        log::printfln("[config/path] omitting path {}: {}", path_str, path::strerror(e));
      case let e: missing_base =>
        log::printfln("[configa/path] omitting path {}: {}", translate_strerror(e));
    };
  };
};

// consider the `pathbuf` in the context of the autodetect `method`, and append
// either that path, its parent, or neither.
fn try_as_path(into: *[]path::buffer, pathbuf: path::buffer, method: autodetect) void = {
  let pathstr = path::string(&pathbuf);
  switch (method) {
    case autodetect::EXISTING =>
      append_if_exists(into, [pathstr], true);
    case autodetect::EXISTING_FILE =>
      append_if_exists(into, [pathstr], false);
    case autodetect::EXISTING_FILE_OR_PARENT =>
      append_if_exists(into, [pathstr], false)
        || append_if_exists(into, [pathstr, ".."], true);
    case autodetect::EXISTING_OR_PARENT =>
      append_if_exists(into, [pathstr], true)
        || append_if_exists(into, [pathstr, ".."], true);
    case autodetect::PARENT =>
      append_if_exists(into, [pathstr, ".."], true);
  };
};

// append the file encoded by `comps`, but only if it exists and is file-like.
// if it exists but as a directory, append it only so long as `dir_ok = true`.
fn append_if_exists(into: *[]path::buffer, comps: []str, dir_ok: bool) bool = {
  let pathbuf = path::buffer { ... };
  let do_append = match (deref_stat(&pathbuf, comps)) {
    case let st: fs::filestat =>
      yield (st.mode & rt::S_IFDIR) == 0 || dir_ok;
    case let e: fs::error =>
      log::printfln("[config/path/try] failed to deref/stat {}: {}", path::string(&pathbuf), fs::strerror(e));
      yield false;
    case let e: path::error =>
      log::printfln("[config/path/try] failed to deref/stat: {}", path::strerror(e));
      yield false;
  };

  if (do_append) {
    log::printfln("[config/path] autodetected path: {}", path::string(&pathbuf));
    append(into, pathbuf);
  } else {
    log::printfln("[config/path/try] not adding path: {}", path::string(&pathbuf));
  };

  return do_append;
};

// invoke `stat` on the path encoded by `comps`.
// if the path is a symlink, deref through the symlinks and stat the target.
fn deref_stat(pathbuf: *path::buffer, comps: []str) (fs::filestat | fs::error | path::error) = {
  *pathbuf = path::init(comps...)?;
  let pathstr = fs::realpath(os::cwd, path::string(pathbuf))?;
  return fs::stat(os::cwd, pathstr);
};

fn translate_strerror(e: (missing_base | fs::error | path::error)) str = {
  return match (e) {
    case let e: missing_base => yield "non-absolute path, but unknown as to which base directory";
    case let e: fs::error => yield fs::strerror(e);
    case let e: path::error => yield path::strerror(e);
  };
};
