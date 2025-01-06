// vim: set shiftwidth=2 :
use errors;
use errors::ext;
use io;
use log;
use path;
use resources;
use restrict::ns;
use rt;

export fn restrict(what: *resources::resources) void = {
  // map the user-requested networking into internal mechanisms:
  let (any_net, pasta_net): (bool, (void | resources::net_subset))
    = match (what.net)
  {
    case resources::net_none =>
      yield (false, void);
    case let subset: resources::net_subset =>
      yield (true, subset);
    case resources::net_all =>
      yield (true, void);
  };

  // map the user-requested dbus settings into internal mechanisms:
  // also, obtain a handle to the bus *before* entering the outer sandbox,
  // so that we can proxy it into the main sandbox.
  let dbus_proxy: (void | dbus_details) = match (what.dbus) {
    case let res: resources::dbus_subset => yield match (get_dbus_session_path()) {
      case let session: path::buffer =>
        // one can't `open` a unix socket, so instead open its parent and later
        // on i can refer to it by path relative to that parent
        let session_parent = path::parent(&session)!;
        log::printfln("[restrict] attempting to open parent(DBUS_SESSION_BUS_ADDRESS={})={}", path::string(&session), session_parent);
        yield match (rt::open(session_parent, rt::O_RDONLY | rt::O_CLOEXEC, 0o700)) { //< TODO: correct mode?
          case let outer_fd: int => yield dbus_details {
            outer_parent_fd = outer_fd,
            session_path = session,
            resources = res,
          };
          case let err: rt::errno =>
            errors::ext::swallow("[restrict] open($DBUS_SESSION_BUS_ADDRESS={})", err, path::string(&session));
            yield void;
        };
      };
      case =>
        log::println("[restrict] dbus requested, but failed to parse dbus session path");
        yield void;
    case void => yield void;
  };

  // sandbox the entire process early, now, before any forking/exec'ing.
  // PID unshares are costly (requires an entire extra long-running supervisor process),
  // so prefer to do that only once, as needed, instead of additionally at the top layer.
  // in turn, this means we have to bind all of `/proc`, both to access
  // `/proc/self` and the proc entries of children (required by e.g. pasta)
  let outer_pid = true;
  // let outer_pid = what.pid;
  let outer_paths: []path::buffer = [];
  for (let p .. what.paths)
    append(outer_paths, p);
  if (outer_pid)
    append(outer_paths, path::init("/proc")!);
  let outer_ns_resources = ns::ns_resources {
    paths = outer_paths,
    ipc = what.ipc,
    net = any_net,
    pid = outer_pid,
    try_users = what.try_users,
  };
  ns::namespace_restrict(&outer_ns_resources);

  match (pasta_net) {
    case void => void;
    case let subset: resources::net_subset =>
      pasta_restrict(subset);
  };

  match (dbus_proxy) {
    case void => void;
    case let details: dbus_details =>

      let st_buf = rt::st { ... };
      match (rt::stat(path::string(&details.session_path), &st_buf)) {
        case void =>
          // the user asked for fs access to the dbus bus,
          // but also asked to proxy it.
          // if we attempted to do that here, it would actually kill the outer,
          // unsandboxed dbus, so don't!
          log::println("[restrict] dbus session bus already exists in sandbox: not proxying");
        case rt::errno =>
          dbus_restrict(details.resources, details.outer_parent_fd, &details.session_path);
          // the bus at this path is now proxied, so grant access to the user.
          // safe to unwrap parent because we only allow absolute bus paths.
          // append(what.paths, path::init(path::parent(&details.session_path)!)!);
          append(what.paths, details.session_path);
      };
  };

  // sandbox the user process
  let user_ns_resources = ns::ns_resources {
    paths = what.paths,
    ipc = what.ipc,
    net = any_net,
    pid = what.pid,
    try_users = what.try_users,
  };
  ns::namespace_restrict(&user_ns_resources);
  capability_restrict(what.caps);
};

type dbus_details = struct {
  outer_parent_fd: io::file,
  session_path: path::buffer,
  resources: resources::dbus_subset,
};
