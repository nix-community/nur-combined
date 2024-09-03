// vim: set shiftwidth=2 :
use errors;
use fmt;
use os;
use rt::ext;

export type cli_opts = struct {
  autodetect: (void | autodetect),
  // command to `exec` within the sandbox
  cmd: []str,
  // `--bunpen-debug`
  debug: uint,
  disable: str,
  drop_shell: bool,
  // `--bunpen-help`
  help: bool,
  home_paths: []str,
  keep_all_caps: bool,
  keep_caps: []rt::ext::cap,
  keep_net: bool,
  keep_pid: bool,
  paths: []str,
  run_paths: []str,
};

export fn usage() void = {
  fmt::println("bunpen: run a program within an environment where access to external resources (files, net, certain IPC, ...) is restricted (i.e. sandbox)")!;
  fmt::println("USAGE: bunpen [sandbox-arg ...] program [sandbox-arg|program-arg ...] [--] [program-arg ...]")!;
  fmt::println("")!;
  fmt::println("sandbox args and program args may be intermixed, but the first `--` anywhere signals the end of the sandbox args and the start of program args")!;
  fmt::println("")!;
  fmt::println("sandbox args:")!;
  fmt::println("  --bunpen-help")!;
  fmt::println("      show this message")!;
  fmt::println("  --bunpen-debug[=n]")!;
  fmt::println("      print debug messages to stderr")!;
  fmt::println("      omit `n` for light debugging, or specify n=0/1/2/3/4 where higher = more verbose")!;
  fmt::println("  --bunpen-drop-shell")!;
  fmt::println("      instead of running the program, drop into an interactive shell")!;
  fmt::println("  --bunpen-autodetect <existing|existingFile|existingFileOrParent|existingOrParent|parent>")!;
  fmt::println("      add files which appear later as CLI arguments into the sandbox")!;
  fmt::println("  --bunpen-cap <all|sys_admin|net_raw|net_admin|...>")!;
  fmt::println("      allow the sandboxed program to use the provided linux capability (both inside and outside the sandbox)")!;
  fmt::println("      special cap 'all' to preserve all capabilities possible")!;
  fmt::println("  --bunpen-keep-net")!;
  fmt::println("      allow unrestricted access to the network")!;
  fmt::println("  --bunpen-keep-pid")!;
  fmt::println("      allow this process to see other processes running on the machine")!;
  fmt::println("  --bunpen-path <path>")!;
  fmt::println("      allow access to the host <path> within the sandbox")!;
  fmt::println("      path is interpreted relative to the working directory if not absolute")!;
  fmt::println("  --bunpen-home-path <path>")!;
  fmt::println("      allow access to the host <path>, relative to HOME")!;
  fmt::println("  --bunpen-run-path <path>")!;
  fmt::println("      allow access to the host <path>, relative to XDG_RUNTIME_DIR")!;
  fmt::println("the following environment variables are also considered and propagated to children:")!;
  fmt::println("  BUNPEN_DISABLE=1 or BUNPEN_DISABLE=all")!;
  fmt::println("      disables all sandboxing; exec the wrapped program directly")!;
  fmt::println("  BUNPEN_DISABLE=progname")!;
  fmt::println("      disables sandboxing for the specific 'progname'")!;
  fmt::println("      any regular expression can be used here, e.g. 'sane-.*' would disable sanboxing for sane-which, sane-open, and so on")!;
  fmt::println("      note that this doesn't enforce a complete match:")!;
  fmt::println("      BUNPEN_DISABLE=host would disable sandboxing for 'host', 'hostname', and so on")!;
  fmt::println("      consider BUNPEN_DISABLE='host$' to be more targeted")!;
  // fmt::println("  --bunpen-add-pwd")!;
  // fmt::println("      shorthand for `--bunpen-path $PWD`")!;
  // fmt::println("")!;
  // fmt::println("  --bunpen-disable")!;
  // fmt::println("      invoke the program directly, instead of inside a sandbox")!;
  // fmt::println("  --bunpen-dry-run")!;
  // fmt::println("      show what would be `exec`uted but do not perform any action")!;
  // fmt::println("  --bunpen-method <bwrap|capshonly|pastaonly|landlock|none>")!;
  // fmt::println("      use a specific sandboxer")!;
  // fmt::println("  --bunpen-net-dev <iface>|all")!;
  // fmt::println("  --bunpen-net-gateway <ip-address>")!;
  // fmt::println("  --bunpen-dns <server>|host")!;
  // fmt::println("  --bunpen-keep-namespace <all|cgroup|ipc|net|pid|uts>")!;
  // fmt::println("      do not unshare the provided linux namespace")!;
  // fmt::println("  BUNPEN_DEBUG=1")!;
  // fmt::println("      equivalent to `--bunpen-debug`, but activates earlier")!;
  // fmt::println("  BUNPEN_PREPEND=...")!;
  // fmt::println("      act as though the provided arg string appeared at the start of the CLI")!;
  // fmt::println("  BUNPEN_APPEND=...")!;
  // fmt::println("      act as though the provided arg string appeared at the end of the CLI")!;
};

export fn parse_args(args: []str) (cli_opts | errors::invalid) = {
  let parsed = cli_opts { autodetect = void, ... };

  parsed.disable = match (os::getenv("BUNPEN_DISABLE")) {
    case let d: str => yield d;
    case void => yield "";
  };

  for (let idx: size = 0; idx < len(args); idx += 1) {
    let arg = args[idx];
    let next: nullable *str = null;
    if (idx + 1 < len(args)) {
      next = &args[idx+1];
    };
    switch (arg) {
      case "--bunpen-autodetect"  =>  idx += 1; parsed.autodetect = autodetect_fromstr(expect_arg("--bunpen-autodetect", next)?)?;
      case "--bunpen-cap"  =>  idx += 1; parse_caparg(&parsed, expect_arg("--bunpen-cap", next)?)?;
      case "--bunpen-debug"       =>  parsed.debug = 2;
      case "--bunpen-debug=0"     =>  parsed.debug = 0;
      case "--bunpen-debug=1"     =>  parsed.debug = 1;
      case "--bunpen-debug=2"     =>  parsed.debug = 2;
      case "--bunpen-debug=3"     =>  parsed.debug = 3;
      case "--bunpen-debug=4"     =>  parsed.debug = 4;
      case "--bunpen-drop-shell"  =>  parsed.drop_shell = true;
      case "--bunpen-help"        =>  parsed.help = true;
      case "--bunpen-home-path"   =>  idx += 1; append(parsed.home_paths, expect_arg("--bunpen-home-path", next)?);
      case "--bunpen-keep-net"    =>  parsed.keep_net = true;
      case "--bunpen-keep-pid"    =>  parsed.keep_pid = true;
      case "--bunpen-path"        =>  idx += 1; append(parsed.paths, expect_arg("--bunpen-path", next)?);
      case "--bunpen-run-path"    =>  idx += 1; append(parsed.run_paths, expect_arg("--bunpen-run-path", next)?);
      case                        =>  append(parsed.cmd, arg);
    };
  };

  return parsed;
};

fn expect_arg(name: str, value: nullable *str) (str | errors::invalid) = {
  return match (value) {
    case null => yield errors::invalid;
    case let v: *str => yield *v;
  };
};

fn parse_caparg(into: *cli_opts, arg: str) (void | errors::invalid) = {
  if (arg == "all") {
    into.keep_all_caps = true;
  } else {
    append(into.keep_caps, rt::ext::cap_fromstr(arg)?);
  };
};
