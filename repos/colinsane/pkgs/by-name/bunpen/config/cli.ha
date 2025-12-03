// vim: set shiftwidth=2 :
use errors;
use fmt;
use strings;
use os;
use rt::ext;

export type cli_opts = struct {
  autodetect: (void | autodetect),
  // command to `exec` within the sandbox
  cmd: []str,
  // `--bunpen-debug`
  debug: uint,
  disable: str,
  drop_shell: str,
  // [ "KEY=VALUE" ]
  env: []str,
  // `--bunpen-help`
  help: bool,
  keep_all_caps: bool,
  keep_caps: []rt::ext::cap,
  keep_ipc: bool,
  keep_net: bool,
  keep_pid: bool,
  paths: []str,
  try_keep_users: bool,

  dbus_call: []str,
  dbus_own: []str,

  net_dev: str,
  net_gateway: str,
  dns: str,
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
  fmt::println("  --bunpen-env FOO=VALUE")!;
  fmt::println("      set the environment variable FOO to VALUE within the launched program")!;
  fmt::println("      a limited set of env vars are expanded within each expression: see PARAMETERIZATION")!;
  fmt::println("  --bunpen-autodetect <existing|existingDir|existingFile|existingFileOrParent|existingDirOrParent|existingOrParent|parent>")!;
  fmt::println("      add files which appear later as CLI arguments into the sandbox")!;
  fmt::println("      shell expansion (PARAMETERIZATION) is NOT performed on these paths")!;
  fmt::println("  --bunpen-cap <all|sys_admin|net_raw|net_admin|...>")!;
  fmt::println("      allow the sandboxed program to use the provided linux capability (both inside and outside the sandbox)")!;
  fmt::println("      special cap 'all' to preserve all capabilities possible")!;
  fmt::println("  --bunpen-keep-ipc")!;
  fmt::println("      allow this process to talk to other processes in the same 'IPC namespace' (rarely needed)")!;
  fmt::println("  --bunpen-keep-net")!;
  fmt::println("      allow unrestricted access to the network")!;
  fmt::println("  --bunpen-keep-pid")!;
  fmt::println("      allow this process to see other processes running on the machine")!;
  fmt::println("  --bunpen-try-keep-users")!;
  fmt::println("      if we have permissions to perform all other operations without creating a new user namespace, then don't create a user namespace")!;
  fmt::println("  --bunpen-path <path>")!;
  fmt::println("      allow access to the host <path> within the sandbox")!;
  fmt::println("      path is interpreted relative to the working directory if not absolute")!;
  fmt::println("      a limited set of env vars are expanded within each path: see PARAMETERIZATION")!;
  fmt::println("  --bunpen-seal")!;
  fmt::println("      halt argument parsing")!;
  fmt::println("      any remaining arguments are to be interpreted as arguments for the user program, not bunpen")!;
  fmt::println("      note that remaining arguments *are* still eligible for path autodetection (see --bunpen-autodetect)")!;
  fmt::println("")!;
  fmt::println("dbus proxy settings (applies to session bus only):")!;
  fmt::println("  --bunpen-dbus-call <name>=<method-spec>")!;
  fmt::println("    method-spec: [*|org.the.interface.[method|*]]|[@/obj/path[/*]]")!;
  fmt::println("    e.g. org.gnome.Calls=*")!;
  fmt::println("    e.g. org.gnome.Calls=org.gtk.Application.Activate")!;
  fmt::println("    e.g. org.gnome.Calls=org.freedesktop.DBus.Introspectable.*")!;
  fmt::println("    e.g. org.gnome.Calls=org.gtk.Application.Activate@/org/gnome/Calls")!;
  fmt::println("  --bunpen-dbus-own <name>")!;
  fmt::println("")!;
  fmt::println("net proxy settings (typical invocation specifies either ALL or NONE of these):")!;
  fmt::println("  --bunpen-net-dev <iface>")!;
  fmt::println("  --bunpen-net-gateway <ip-address>")!;
  fmt::println("  --bunpen-dns <server>")!;
  fmt::println("")!;
  fmt::println("ENVIRONMENT")!;
  fmt::println("the following environment variables are also considered and propagated to children:")!;
  fmt::println("  BUNPEN_DEBUG=n")!;
  fmt::println("      equivalent to `--bunpen-debug=n`")!;
  fmt::println("  BUNPEN_DISABLE=1 or BUNPEN_DISABLE=all")!;
  fmt::println("      disables all sandboxing; exec the wrapped program directly")!;
  fmt::println("  BUNPEN_DISABLE=progname")!;
  fmt::println("      disables sandboxing for the specific 'progname'")!;
  fmt::println("      any regular expression can be used here, e.g. 'sane-.*' would disable sanboxing for sane-which, sane-open, and so on")!;
  fmt::println("      note that this doesn't enforce a complete match:")!;
  fmt::println("      BUNPEN_DISABLE=host would disable sandboxing for 'host', 'hostname', and so on")!;
  fmt::println("      consider BUNPEN_DISABLE='host$' to be more targeted")!;
  fmt::println("  BUNPEN_DROP_SHELL=<specifier>")!;
  fmt::println("      instead of running the program, drop into an interactive shell")!;
  fmt::println("      uses the same specifier syntax as BUNPEN_DISABLE")!;
  fmt::println("  BUNPEN_APPEND=--bunpen-flag1 --bunpen-flag2 ...")!;
  fmt::println("      act as though the provided arg string appeared at the end of the CLI")!;
  fmt::println("")!;
  fmt::println("PARAMETERIZATION")!;
  fmt::println("where noted, the following variables are expanded in the style of shell expansion:")!;
  fmt::println("  $HOME")!;
  fmt::println("  $XDG_RUNTIME_DIR")!;
  fmt::println("  $$ to escape a literal $")!;

  // fmt::println("  --bunpen-add-pwd")!;
  // fmt::println("      shorthand for `--bunpen-path $PWD`")!;
  // fmt::println("")!;
  // fmt::println("  --bunpen-disable")!;
  // fmt::println("      invoke the program directly, instead of inside a sandbox")!;
  // fmt::println("  --bunpen-dry-run")!;
  // fmt::println("      show what would be `exec`uted but do not perform any action")!;
  // fmt::println("  --bunpen-method <bwrap|capshonly|pastaonly|landlock|none>")!;
  // fmt::println("      use a specific sandboxer")!;
  // fmt::println("  --bunpen-keep-namespace <all|cgroup|ipc|net|pid|uts>")!;
  // fmt::println("      do not unshare the provided linux namespace")!;
  // fmt::println("  BUNPEN_PREPEND=...")!;
  // fmt::println("      act as though the provided arg string appeared at the start of the CLI")!;
};

export fn parse_args(args: []str) (cli_opts | errors::invalid) = {
  let parsed = cli_opts { autodetect = void, ... };

  match (os::getenv("BUNPEN_DISABLE")) {
    case let d: str => parsed.disable = d;
    case void => void;
  };
  match (os::getenv("BUNPEN_DEBUG")) {
    case let d: str => switch (d) {
      case "0" => parsed.debug = 0;
      case "1" => parsed.debug = 1;
      case "2" => parsed.debug = 2;
      case "3" => parsed.debug = 3;
      case "4" => parsed.debug = 4;
      case => void;
    };
    case void => void;
  };
  match (os::getenv("BUNPEN_DROP_SHELL")) {
    case let d: str => parsed.drop_shell = d;
    case void => void;
  };

  parse_args_into(&parsed, args)?;

  match (os::getenv("BUNPEN_APPEND")) {
    case let a: str =>
      let append_args_raw = strings::split(a, " ");
      defer free(append_args_raw);
      // handle `BUNPEN_APPEND="  arg1 arg2   arg3 "` leading/mid/trailing whitespace:
      let append_args: []str = [];
      defer free(append_args);
      for (let a .. append_args_raw) {
        if (a != "")
          append(append_args, a);
      };
      parse_args_into(&parsed, append_args)?;
    case void => void;
  };

  return parsed;
};

fn parse_args_into(parsed: *cli_opts, args: []str) (void | errors::invalid) = {
  let parsing_bunpen = true;
  for (let idx: size = 0; idx < len(args); idx += 1) {
    let arg = args[idx];
    let next: nullable *str = null;
    if (idx + 1 < len(args)) {
      next = &args[idx+1];
    };
    if (parsing_bunpen) {
      switch (arg) {
        case "--bunpen-autodetect"      =>  idx += 1; parsed.autodetect = autodetect_fromstr(expect_arg("--bunpen-autodetect", next)?)?;
        case "--bunpen-cap"             =>  idx += 1; parse_caparg(parsed, expect_arg("--bunpen-cap", next)?)?;
        case "--bunpen-dbus-call"       =>  idx += 1; append(parsed.dbus_call, expect_arg("--bunpen-dbus-call", next)?);
        case "--bunpen-dbus-own"        =>  idx += 1; append(parsed.dbus_own, expect_arg("--bunpen-dbus-own", next)?);
        case "--bunpen-debug"           =>  parsed.debug = 2;
        case "--bunpen-debug=0"         =>  parsed.debug = 0;
        case "--bunpen-debug=1"         =>  parsed.debug = 1;
        case "--bunpen-debug=2"         =>  parsed.debug = 2;
        case "--bunpen-debug=3"         =>  parsed.debug = 3;
        case "--bunpen-debug=4"         =>  parsed.debug = 4;
        case "--bunpen-dns"             =>  idx += 1; parsed.dns = expect_arg("--bunpen-dns", next)?;
        case "--bunpen-drop-shell"      =>  parsed.drop_shell = "1";
        case "--bunpen-env"             =>  idx += 1; append(parsed.env, expect_arg("--bunpen-env", next)?);
        case "--bunpen-help"            =>  parsed.help = true;
        case "--bunpen-keep-ipc"        =>  parsed.keep_ipc = true;
        case "--bunpen-keep-net"        =>  parsed.keep_net = true;
        case "--bunpen-keep-pid"        =>  parsed.keep_pid = true;
        case "--bunpen-net-dev"         =>  idx += 1; parsed.net_dev = expect_arg("--bunpen-net-dev", next)?;
        case "--bunpen-net-gateway"     =>  idx += 1; parsed.net_gateway = expect_arg("--bunpen-net-gateway", next)?;
        case "--bunpen-path"            =>  idx += 1; append(parsed.paths, expect_arg("--bunpen-path", next)?);
        case "--bunpen-seal"            =>  parsing_bunpen = false;  // remaining arguments are not to be interpreted by us
        case "--bunpen-try-keep-users"  =>  parsed.try_keep_users = true;
        case                            =>  append(parsed.cmd, arg);
      };
    } else {
      append(parsed.cmd, arg);
    };
  };
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
