// vim: set shiftwidth=2 :
use path;
use rt::ext;

export type resources = struct {
  // paths to allow unrestricted access to (i.e. with whatever permissions the
  // user has naturally.
  paths: []path::buffer,
  caps: rt::ext::caps,
  dbus: (void | dbus_subset),
  // true to allow speaking to other processes in the same IPC namespace
  ipc: bool,
  net: net_resources,
  // true to allow operations on other processes (e.g. viewing their cmdline,
  // killing them, etc).
  pid: bool,
  // try to keep access to the current user namespace, but let it go if holding
  // onto it would prevent us from sandboxing further
  try_users: bool,
};

export type dbus_subset = struct {
  // list of method specifiers to allow calling
  //   <name>=<method-spec>
  //   method-spec: [*|org.the.interface.[method|*]]|[@/obj/path[/*]]
  //   e.g. org.gnome.Calls=org.gtk.Application.Activate@/org/gnome/Calls
  call: []str,
  // list of bus names to allow owning
  own: []str,
};

export type net_subset = struct {
  // name of the network device through which traffic should be routed
  dev: str,
  // IP address of a DNS server reachable through these other settings
  dns: str,
  // IP address of the gateway, by which traffic will be routed
  gateway: str,
};
export type net_none = void;
export type net_all = void;
export type net_resources = (net_none | net_subset | net_all);
