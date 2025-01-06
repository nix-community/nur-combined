// vim: set shiftwidth=2 :
//
// xdg-dbus-proxy sits between a dbus client and a dbus bus and selectively
// forwards messages between the two.
//
// intended xdg-dbus-proxy use looks like:
// 1. invoke `xdg-dbus-proxy unix:path=/unfiltered/bus /filtered/bus --filter --talk=org.foo.Bar --own=org.baz.Bap`
// 2. in a different process, restrict mount namespace so that `/unfiltered/bus` isn't viewable.
//    set the environment variable: DBUS_SESSION_BUS_ADDRESS=unix:path=/filtered/bus.
//    execute your dbus client.
// 3. the resulting setup is one where the client may:
//    - talk to whatever owns `org.foo.Bar`.
//    - see `org.foo.Bar` on the bus, and see the bus itself, but not see any
//    other dbus names.
//    - own the dbus name `org.baz.Bap`.
//
// `man xdg-dbus-proxy` provides this example invocation:
// `xdg-dbus-proxy --fd=26 unix:path=/run/usr/1000/bus /run/usr/1000/.dbus-proxy/session-bus-proxy --filter --own=org.gnome.ghex.* --talk=ca.desrt.dconf --call=org.freedesktop.portal.*=* --broadcast=org.freedesktop.portal.*=@/org/freedesktop/portal/*`
//
// proof-of-concept minimal:
// ```sh
// $ xdg-dbus-proxy unix:path=/run/user/colin/dbus/bus /run/user/colin/dbus/proxy-1 --filter &
// $ DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/colin/dbus/proxy-1 busctl --user list
// # should show *only* the bus, and no clients
// ```
//
// proof-of-concept TALK:
// ```sh
// $ xdg-dbus-proxy unix:path=/run/user/colin/dbus/bus /run/user/colin/dbus/proxy-1 --talk=org.gnome.Calls --filter &
// $ DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/colin/dbus/proxy-1 gdbus call --session --dest=org.gnome.Calls --object-path /org/gnome/Calls --method org.gtk.Application.Activate '[]'
// # the gnome-calls window should now be highlighted (assuming that's how it responds to an activation request)
// # take away `--talk=org.gnome.Calls`, and the final step should get EPERM instead
// ```
//
// proof-of-concept CALL (more highly locked down):
// ```sh
// $ xdg-dbus-proxy unix:path=/run/user/colin/dbus/bus /run/user/colin/dbus/proxy-1 --filter '--call=org.gnome.Calls=org.gtk.Application.Activate@/org/gnome/Calls' '--call=org.gnome.Calls=org.freedesktop.DBus.Introspectable.Introspect@/org/gnome/Calls'
// $ DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/colin/dbus/proxy-1 gdbus call --session --dest=org.gnome.Calls --object-path /org/gnome/Calls --method org.gtk.Application.Activate '[]'
// # works.
// # remove either of the `--call` options, and it fails
// # this less specific proxy option also works:
// $ xdg-dbus-proxy unix:path=/run/user/colin/dbus/bus /run/user/colin/dbus/proxy-1 --filter '--call=org.gnome.Calls=org.gtk.Application.Activate' '--call=org.gnome.Calls=org.freedesktop.DBus.Introspectable.Introspect'
// ```
//
// proof-of-concept OWN:
// ```sh
// $ xdg-dbus-proxy unix:path=/run/user/colin/dbus/bus /run/user/colin/dbus/proxy-1 --filter '--own=org.mpris.MediaPlayer2.playerctld' &
// $ DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/colin/dbus/proxy-1 playerctld
// ```
//
// EDGE-CASES / FAQ:
// - run `xdg-dbus-proxy` with `--log` argument to dump intercepted traffiic
// - without `--filter`, the proxy allows ALL traffic (useless!)
// - with `--filter`, and no other flags, proxy denies all messages (except messages to the bus)
// - `--talk=org.gnome.Calls` implies `--see=org.gnome.Calls`
// - `--own=org.gnome.Calls` implies `--talk=org.gnome.Calls` (and --see=...)
// - `--talk=org.gnome.Calls` allows calling *any* method on the object which owns org.gnome.Calls
// - `--call=NAME=INTERFACE.METHOD@/PATH` implies some *subset* of `--talk=NAME`, as necessary,
//    as well it implies `--see=NAME`.
//    - wildcards are supported above as expected (e.g. `'--call=org.gnome.Calls=org.gtk.Application.*@*'`
// - best is to use exclusively `--call=...` rules (and `--own`), no --see or --talk

use config;
use errors;
use errors::ext;
use fmt;
use fs;
use io;
use log;
use os;
use os::exec;
use path;
use ps;
use resources;
use restrict::ns;
use rt;
use rt::ext;
use strings;
use unix;

// given an existing, unfiltered bus at the fs path `upstream`,
// proxy the bus into the fs path indicated by `downstream`.
// clients attaching to the `downstream` path are provided access only to the
// resources indicated by `dbus`.
fn dbus_restrict(dbus: resources::dbus_subset, upstream_parent_fd: io::file, downstream_path: *const path::buffer) void = {
  log::printfln("[dbus] restricting...");
  errors::ext::swallow(
    "[dbus] os::mkdirs(path::parent($DBUS_SESSION_BUS_ADDRESS={}))",
    dbus_ensure_bus_dir(downstream_path),
    path::string(downstream_path),
  );

  // pipe by which child xdg-dbus-proxy can notify the parent of readiness
  let (pipe_parent_rd, pipe_child_wr) = unix::pipe()!;
  log::printfln("[dbus]: forking: child will launch xdg-dbus-proxy while parent will exec user code");
  match (ps::fork_and_die_with_parent()) {
    case void =>
      // ~~close the pipe ends which aren't ours~~
      // actually DON'T: the xdg-dbus-proxy `--fd=FOO` notification option
      // causes xdg-dbus-proxy to exit when the fd is closed.
      // we COULD keep the fd open in the parent, but that only works so long as
      // it stays around as a PID-0 manager, and not in the cases where it
      // directly exec's the user code.
      //
      // so, keep the `--fd=pipe_parent_rd` fd open here, and intentionally let
      // the xdg-dbus-proxy process inherit that. it'll never be closed so long as the proxy is alive
      // io::close(pipe_parent_rd)!;

      let ns_paths: []path::buffer = [];
      append(ns_paths, path::init("/nix/store")!);
      // TODO: pre-eval the path to `xdg-dbus-proxy` here and remove this /run directory?
      append(ns_paths, path::init("/run/current-system/sw/bin")!);
      match (path::parent(downstream_path)) {
        case let p: str => append(ns_paths, path::init(p)!);
        case let e: path::error => errors::ext::swallow("[dbus] path::parent($DBUS_SESSION_BUS_ADDRESS)", e);
      };
      let ns_resources = ns::ns_resources {
        paths = ns_paths,
        ...
      };
      ns::namespace_restrict(&ns_resources);

      // `dup` the fd's we need to share with xdg-dbus-proxy since the originals are O_CLOEXEC.
      let upstream_parent_fd_nocloexec = rt::dup(upstream_parent_fd)!;
      let upstream_fd_path = fmt::asprintf(
        "unix:path=/proc/self/fd/{}/{}",
        upstream_parent_fd_nocloexec: int,
        path::basename(path::string(downstream_path)),
      );
      let notify_fd_nocloexec = rt::dup(pipe_child_wr)!;

      let proxy_args: []str = [];
      append(proxy_args, "xdg-dbus-proxy");
      append(proxy_args, upstream_fd_path);
      append(proxy_args, path::string(downstream_path));
      append(proxy_args, "--filter");
      append(proxy_args, fmt::asprintf("--fd={}", notify_fd_nocloexec: int));
      // append(proxy_args, "--log");
      for (let spec .. dbus.call) {
        append(proxy_args, fmt::asprintf("--call={}", spec));
      };
      for (let spec .. dbus.own) {
        append(proxy_args, fmt::asprintf("--own={}", spec));
      };
      errors::ext::check(
        "dbus_restrict: invoke xdg-dbus-proxy",
        rt::ext::execvpe_or_default(
          config::XDG_DBUS_PROXY,
          "xdg-dbus-proxy",
          proxy_args,
          os::getenvs(),
        ),
      );
    case let child_pid: os::exec::process =>
      // close the pipe ends which aren't ours
      io::close(pipe_child_wr)!;

      // wait for the proxy to signal readiness
      io::readall(pipe_parent_rd, &[0u8])!;

      log::println("[dbus] child signaled readiness: continuing");

      io::close(pipe_parent_rd)!;

    case let e: (os::exec::error | rt::errno) =>
      errors::ext::check("dbus_restrict: fork", e);
  };
};

fn dbus_ensure_bus_dir(downstream_path: *const path::buffer) (void | fs::error | path::error) = {
  let downstream_dir = path::parent(downstream_path)?;
  log::printfln("[dbus] mkdir({})", downstream_dir);
  os::mkdirs(downstream_dir, 0o700)?;
};

fn parse_dbus_address(address: (str | void)) (path::buffer | path::error) = {
  // dbus address is specified like:
  // DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/colin/dbus/bus
  return match (address) {
    case void => yield path::not_prefix;
    case let value: str =>
      let expected_prefix = "unix:path=";
      if (!strings::hasprefix(value, expected_prefix)) {
        return path::not_prefix;
      };
      value = strings::sub(value, len(expected_prefix));
      if (!path::abs(value)) {
        // expect the dbus bus address to be an absolute path
        return path::not_prefix;
      };
      yield path::init(value);
  };
};

fn get_dbus_session_path() (path::buffer | path::error) = {
  return parse_dbus_address(os::getenv("DBUS_SESSION_BUS_ADDRESS"));
};


//---- TESTS ----//

fn _dbus_address_eq(value: (str | void), expect: (str | path::error)) bool = {
  return match (expect) {
    case let s: str => yield match (parse_dbus_address(value)) {
      case let s2: path::buffer => yield path::string(&s2) == s;
      case => yield false;
    };
    case let e: path::error => yield match (parse_dbus_address(value)) {
      // not picky about the precise error, just that if we expect *an* error
      // then we get *an* error.
      case let e2: path::error => yield true;
      case => yield false;
    };
  };
};

@test fn get_dbus_session_path_good() void = {
  assert(_dbus_address_eq("unix:path=/dbus/good", "/dbus/good"));
};

@test fn get_dbus_session_path_relative_path() void = {
  assert(_dbus_address_eq("unix:path=dbus/bad", path::not_prefix));
};
@test fn get_dbus_session_path_empty_path() void = {
  assert(_dbus_address_eq("unix:path=", path::not_prefix));
};
@test fn get_dbus_session_path_missing_path() void = {
  assert(_dbus_address_eq("unix:path", path::not_prefix));
};
@test fn get_dbus_session_path_missing_type() void = {
  assert(_dbus_address_eq("", path::not_prefix));
};
@test fn get_dbus_session_path_wrong_type() void = {
  assert(_dbus_address_eq("msnt:path=/dbus/path", path::not_prefix));
};

@test fn get_dbus_session_path_unset() void = {
  assert(_dbus_address_eq(void, path::not_prefix));
};
