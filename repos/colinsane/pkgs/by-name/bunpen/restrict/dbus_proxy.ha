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
use strings;
use os;
use os::exec;
use ps;
use rt::ext;

export type dbus_resources = struct {
  talk: []str,
  own: []str,
};

// given an existing, unfiltered bus at the fs path `upstream`,
// proxy the bus into the fs path indicated by `downstream`.
// clients attaching to the `downstream` path are provided access only to the
// resources indicated by `dbus`.
fn dbus_restrict(dbus: dbus_resources, upstream: str, downstream: str) void = {
  match (ps::fork_and_die_with_parent()) {
    case let child_pid: os::exec::process =>
      let proxy_args: []str = [
        "xdg-dbus-proxy",
        "--filter",
      ];
      for (let spec .. dbus.talk) {
        append(proxy_args, "--talk");
        append(proxy_args, spec);
      };
      for (let spec .. dbus.own) {
        append(proxy_args, "--own");
        append(proxy_args, spec);
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
    case void =>
      // xdg-dbus-proxy provides no explicit synchronization mechanism;
      // we have to assume that once we fork, it starts listening "reasonably quickly".
      // TODO: i could probably hack some synchronization in here:
      // - `write` a HELLO message and block until it's read.
      // - invoke with `--log` and parse the output.
      // - or maybe pre-create the unix socket _before_ forking here, and
      //   somehow pass that into xdg-dbus-proxy instead of letting it create
      //   its own socket.
      void;
  };
};


fn parse_dbus_address(address: (str | void)) (str | errors::invalid) = {
  // dbus address is specified like:
  // DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/colin/dbus/bus
  return match (address) {
    case void => yield errors::invalid;
    case let value: str =>
      let expected_prefix = "unix:path=";
      if (!strings::hasprefix(value, expected_prefix)) {
        return errors::invalid;
      };
      value = strings::sub(value, len(expected_prefix));
      if (!strings::hasprefix(value, "/")) {
        // expect the dbus bus address to be an absolute path
        // TODO: consider parsing this as an actual path?
        return errors::invalid;
      };
      yield value;
  };
};

fn get_dbus_session_path() (str | errors::invalid) = {
  return parse_dbus_address(os::getenv("DBUS_SESSION_BUS_ADDRESS"));
};

fn _dbus_address_eq(value: (str | void), expect: (str | errors::invalid)) bool = {
  return match (expect) {
    case let s: str => yield match (parse_dbus_address(value)) {
      case let s2: str => yield s2 == s;
      case => yield false;
    };
    case let e: errors::invalid => yield match (parse_dbus_address(value)) {
      case errors::invalid => yield true;
      case => yield false;
    };
  };
};

@test fn get_dbus_session_path_good() void = {
  assert(_dbus_address_eq("unix:path=/dbus/good", "/dbus/good"));
};

@test fn get_dbus_session_path_relative_path() void = {
  assert(_dbus_address_eq("unix:path=dbus/bad", errors::invalid));
};
@test fn get_dbus_session_path_empty_path() void = {
  assert(_dbus_address_eq("unix:path=", errors::invalid));
};
@test fn get_dbus_session_path_missing_path() void = {
  assert(_dbus_address_eq("unix:path", errors::invalid));
};
@test fn get_dbus_session_path_missing_type() void = {
  assert(_dbus_address_eq("", errors::invalid));
};
@test fn get_dbus_session_path_wrong_type() void = {
  assert(_dbus_address_eq("msnt:path=/dbus/path", errors::invalid));
};

@test fn get_dbus_session_path_unset() void = {
  assert(_dbus_address_eq(void, errors::invalid));
};
