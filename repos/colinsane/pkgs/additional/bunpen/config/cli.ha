// vim: set shiftwidth=2 :
use fmt;
use os;

export type cli_opts = struct {
  // command to `exec` within the sandbox
  cmd: []str,
  // `--bunpen-debug`
  debug: bool,
  drop_shell: bool,
  // `--bunpen-help`
  help: bool,
  keep_net: bool,
  paths: []str,
};

export fn usage() void = {
  fmt::println("bunpen: run a program within an environment where access to external resources (files, net) is restricted (i.e. sandbox)")!;
  fmt::println("USAGE: bunpen [sandbox-arg ...] program [sandbox-arg|program-arg ...] [--] [program-arg ...]")!;
  fmt::println("")!;
  fmt::println("sandbox args and program args may be intermixed, but the first `--` anywhere signals the end of the sandbox args and the start of program args")!;
  fmt::println("")!;
  fmt::println("sandbox args:")!;
  fmt::println("  --bunpen-help")!;
  fmt::println("      show this message")!;
  fmt::println("  --bunpen-debug")!;
  fmt::println("      print debug messages to stderr")!;
  fmt::println("  --bunpen-drop-shell")!;
  fmt::println("      instead of running the program, drop into an interactive shell")!;
  // fmt::println("  --bunpen-replace-cli <bin>")!;
  // fmt::println("      invoke <bin> under the sandbox instead of any program previously listed")!;
  // fmt::println("      also clears and earlier arguments intended for the program")!;
  // fmt::println("  --bunpen-disable")!;
  // fmt::println("      invoke the program directly, instead of inside a sandbox")!;
  // fmt::println("  --bunpen-dry-run")!;
  // fmt::println("      show what would be `exec`uted but do not perform any action")!;
  // fmt::println("  --bunpen-method <bwrap|capshonly|pastaonly|landlock|none>")!;
  // fmt::println("      use a specific sandboxer")!;
  // fmt::println("  --bunpen-autodetect <existing|existingFile|existingFileOrParent|existingOrParent|parent>")!;
  // fmt::println("      add files which appear later as CLI arguments into the sandbox")!;
  // fmt::println("  --bunpen-cap <all|sys_admin|net_raw|net_admin|...>")!;
  // fmt::println("      allow the sandboxed program to use the provided linux capability (both inside and outside the sandbox)")!;
  // fmt::println("      special cap "all" to preserve all capabilities possible")!;
  // fmt::println("  --bunpen-bwrap-arg <arg>")!;
  // fmt::println("  --bunpen-capsh-arg <arg>")!;
  // fmt::println("  --bunpen-pasta-arg <arg>")!;
  // fmt::println("  --bunpen-net-dev <iface>|all")!;
  // fmt::println("  --bunpen-net-gateway <ip-address>")!;
  // fmt::println("  --bunpen-dns <server>|host")!;
  // fmt::println("  --bunpen-keep-namespace <all|cgroup|ipc|net|pid|uts>")!;
  // fmt::println("      do not unshare the provided linux namespace")!;
  fmt::println("  --bunpen-keep-net")!;
  fmt::println("      allow unrestricted access to the network")!;
  fmt::println("  --bunpen-path <path>")!;
  fmt::println("      allow access to the host <path> within the sandbox")!;
  fmt::println("      path is interpreted relative to the working directory if not absolute")!;
  // fmt::println("  --bunpen-home-path <path>")!;
  // fmt::println("      allow access to the host <path>, relative to HOME")!;
  // fmt::println("  --bunpen-run-path <path>")!;
  // fmt::println("      allow access to the host <path>, relative to XDG_RUNTIME_DIR")!;
  // fmt::println("  --bunpen-add-pwd")!;
  // fmt::println("      shorthand for `--bunpen-path $PWD`")!;
  // fmt::println("")!;
  // fmt::println("the following environment variables are also considered and propagated to children:")!;
  // fmt::println("  BUNPEN_DISABLE=1")!;
  // fmt::println("      equivalent to `--bunpen-disable`")!;
  // fmt::println("  BUNPEN_DEBUG=1")!;
  // fmt::println("      equivalent to `--bunpen-debug`, but activates earlier")!;
  // fmt::println("  BUNPEN_PREPEND=...")!;
  // fmt::println("      act as though the provided arg string appeared at the start of the CLI")!;
  // fmt::println("  BUNPEN_APPEND=...")!;
  // fmt::println("      act as though the provided arg string appeared at the end of the CLI")!;
};

export fn parse_args(args: []str) cli_opts = {
  let parsed = cli_opts { ... };

  for (let idx: size = 0; idx < len(args); idx += 1) {
    let arg = args[idx];
    let next: nullable *str = null;
    if (idx + 1 < len(args)) {
      next = &args[idx+1];
    };
    switch (arg) {
      case "--bunpen-debug"       =>  parsed.debug = true;
      case "--bunpen-drop-shell"  => parsed.drop_shell = true;
      case "--bunpen-help"        =>  parsed.help = true;
      case "--bunpen-keep-net"    =>  parsed.keep_net = true;
      case "--bunpen-path"        =>  idx += 1; append(parsed.paths, expect_arg("--bunpen-path", next));
      case                        =>  append(parsed.cmd, arg);
    };
  };

  return parsed;
};

fn expect_arg(name: str, value: nullable *str) str = {
  match (value) {
    case null => usage(); os::exit(1);
    case let v: *str => return *v;
  };
};
