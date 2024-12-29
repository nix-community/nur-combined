// vim: set shiftwidth=2 :
use path;
use resources;
use restrict::ns;

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
