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

// use config;
// use errors;
// use errors::ext;
// use os;
// use os::exec;
// 
// // instantiate a `xdg-dbus-proxy` process,
// //   which talks to the bus on the sandboxed process's behalf,
// //   selectively forwarding traffic based on the passed policy.
// // this can be called from within an existing sandbox.
// //   the dbus bus should be reachable from the present namespace.
// //   xdg-dbus-proxy will run in this namespace,
// //
// // `man xdg-dbus-proxy` provides this example invocation:
// // `xdg-dbus-proxy --fd=26 unix:path=/run/usr/1000/bus /run/usr/1000/.dbus-proxy/session-bus-proxy --filter --own=org.gnome.ghex.* --talk=ca.desrt.dconf --call=org.freedesktop.portal.*=* --broadcast=org.freedesktop.portal.*=@/org/freedesktop/portal/*`
// fn setup_dbus_proxy(dbus: restrict::dbus_subset) void = {
//   let dbus_socket = errors::ext::check("setup_dbus_proxy: get_dbus_socket", get_dbus_socket());
//   match (os::exec::fork()) {
//     case let child_pid: os::exec::process =>
//       // parent process: continue execution
//       void;
//     case void =>
//       // child process: TODO: spawn xdg-dbus-proxy
//       void;
//     case let e: os::exec::error =>
//       errors::ext::check("setup_dbus_proxy: fork", e);
//   };
// };
// 
// fn get_dbus_socket() (str | errors::error) = {
//   // dbus address is specified like:
//   // DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/colin/dbus/bus
//   return match (os::getenv("DBUS_SESSION_BUS_ADDRESS")) {
//     case void => yield errors::invalid;
//     case let value: str => 
//       let expected_prefix = "unix:path=";
//       if (!strings::hasprefix(value, expected_prefix)) {
//         yield errors::invalid;
//       };
//       value = strings::sub(value, len(expected_prefix));
//       if (!strings::hasprefix(value, "/")) {
//         // expect the dbus bus address to be an absolute path
//         // TODO: consider parsing this as an actual path?
//         yield errors::invalid;
//       };
//       yield value;
//   };
// };
