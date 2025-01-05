// vim: set shiftwidth=2 :

use config;
use errors;
use errors::ext;
use fmt;
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

fn pasta_restrict(net: resources::net_subset) void = {
  // `pasta PID [options]`: creates a device in the netns of PID.
  // ordering:
  // 1. fork  into (P, C1)
  // 2. parent P: enter netns, signal child C1.
  // 3. child C1: exec into `pasta --pid /proc/self/fd/$N --netns /proc/$P/ns/net`
  //    pasta will then wait until `$P` exits, i.e. "forever" from the
  //    perspective of this process.
  // 4. parent P: wait for `pasta` to signal readiness on fd `$N`
  //
  // after that, P can continue on & exec into the user code

  // unshare PID space here so that the fork'd child (pasta) is isolated.
  // TODO: stronger isolation (mount namespace).
  // errors::ext::check("[namespace/pasta] unshare PID", rt::ext::unshare(rt::ext::clone_flag::NEWPID));

  // grab a handle to the namespaces of the primary process.
  // then we can fork, unshare net (in parent) and refer to that unshared netns
  // in the child (pasta) via ${ns_fd}/net.
  let ns_fd = errors::ext::check_int("setup_pasta: open /proc/self/ns", rt::open("/proc/self/ns", rt::O_RDONLY, 0o400));

  let (pipe_parent_rd, pipe_child_wr) = unix::pipe()!;
  let (pipe_child_rd, pipe_parent_wr) = unix::pipe()!;
  log::printfln("[namespace/pasta] forking: child will launch pasta while parent will exec user code");
  match (ps::fork_and_die_with_parent()) {
    case let child_pid: os::exec::process =>
      // close the pipe ends which aren't ours
      io::close(pipe_child_wr)!;
      io::close(pipe_child_rd)!;

      errors::ext::check("namespace: unshare net", rt::ext::unshare(rt::ext::clone_flag::NEWNET));
      errors::ext::check("setup_pasta: config routing", config_routing_in_ns(net));

      // drop enough caps so that pasta has permissions to enter our new netns.
      // TODO: just set the desired caps here, and then don't try to do it again.
      capability_restrict(rt::ext::CAPS_NONE);

      // let the other thread know we're ready for pasta to attach to us
      io::write(pipe_parent_wr, [1u8])!;

      // wait for the other thread to attach pasta.
      // pasta signals readiness by writing its pid (followed by \n) to a file.
      let pasta_pid: [32]u8 = [0...];
      io::read(pipe_parent_rd, &pasta_pid)!;

      log::println("[namespace/pasta] child signaled readiness: continuing");

      // cleanup: we're done with the pipes
      io::close(pipe_parent_wr)!;
      io::close(pipe_parent_rd)!;

    case void =>
      // close the pipe ends which aren't ours
      io::close(pipe_parent_wr)!;
      io::close(pipe_parent_rd)!;

      // wait for the parent to signal that it's ready for us to attach pasta.
      io::readall(pipe_child_rd, &[0u8])!;

      // open the sandboxer's netns, which is at this point disconnected from the outer world.
      let netns_fd = errors::ext::check_int(
        "setup_pasta: open('/proc/self/ns/net')",
        rt::openat2(ns_fd, "net", &rt::open_how { ... }, size(rt::open_how)),
      );

      // restrict which resources pasta itself is provided access:
      let ns_resources = ns::ns_resources {
        paths = [
          path::init("/dev/net/tun")!,
          path::init("/nix/store")!,
          // TODO: pre-eval the path to `pasta` here and remove this /run directory?
          path::init("/run/current-system/sw/bin")!,
        ],
        ipc = false,
        net = true,
        pid = false,
        // TODO: run pasta as an isolated user.
        // dropping user will require some coordination from the layer above:
        // pasta joins the netns of the parent thread: linux allows that so
        // long as the target netns was created by the same user which pasta is
        // running as. hence, this *particular* line here must not unshare user,
        // however the parent could fork an unprivileged user thread before
        // unsharing net, but after unsharing everything else: this thread would
        // then be allowed to join its netns but not any other namespace/resource.
        try_users = true,
        ...
      };
      ns::namespace_restrict(&ns_resources);

      // pasta needs permissions to create a device in the netns (it apparently
      // won't raise those caps itself). TODO: reduce these resources!
      capability_restrict(rt::ext::CAPS_ALL);

      // exec into pasta (never returns)
      errors::ext::check("setup_pasta: attach", attach_pasta(net, netns_fd, pipe_child_wr));

      // XXX: this code below never actually gets run
      // cleanup: we're done with the pipes
      io::close(pipe_child_wr)!;
      io::close(pipe_child_rd)!;

    case let e: (os::exec::error | rt::errno) =>
      errors::ext::check("setup_pasta: fork", e);
  };
};

// spawn pasta as a separate process, and have it attach to the netns of the given pid.
fn attach_pasta(net: resources::net_subset, netns_fd: io::file, notify_fd: io::file) (void | os::exec::error | rt::errno) = {
  // move the fd's to be one of the special fd's which *don't*
  // get closed on exec (e.g. /proc/self/fd/0, stdin).
  // notify_fd is opened O_NOCLOEXEC (netns_fd is O_CLOEXEC), but still this seems to be required,
  //   and it only works if we dup2 to fd 0/1/2 (not >= 3).
  // maybe pasta is doing some security measure like clearing all open fd's EXCEPT stdio on exec.

  rt::dup2(netns_fd, 0)!;
  io::close(netns_fd)!;
  let netns_fd_path = "/proc/self/fd/0";

  rt::dup2(notify_fd, 1)!;
  io::close(notify_fd)!;
  let notify_fd_path = "/proc/self/fd/1";

  let pasta_args = [
    "pasta",
    "--quiet",  //< don't print MAC/DHCP/DNS values  (TODO: enable these for BUNPEN_DEBUG>=1)
    // "--debug",  //< log all traffic
    "--ipv4-only",
    // pasta `up`s `lo` regardless of this flag; `--config-net` just tells
    // it to assign an IP and routes to the new device it creates
    "--config-net",
    // port forwards:
    "-u", "none",
    "-t", "none",
    "-U", "none",
    "-T", "none",
    // "-U", "53",  #< if using the host's DNS
    // "-T", "53",  #< if using the host's DNS
    "--outbound-if4", net.dev,
    "--gateway", net.gateway,
    "--netns-only",
    // pidstr,
    // "--netns", netns_path,
    "--netns", netns_fd_path,
    "--pid", notify_fd_path,
    // pasta daemonizes by default, *specifically* so it can unshare its PID namespace.
    // i'm managing that here though, so we can have it not fork.
    "--foreground",
  ];

  log::printfln("[namespace/pasta]: invoking pasta: {}", strings::join(" ", pasta_args...));
  return rt::ext::execvpe_or_default(
    config::PASTA,
    "pasta",
    pasta_args,
    os::getenvs(),
  );
};

fn config_routing_in_ns(net: resources::net_subset) (void | os::exec::error | rt::errno) = {
  // raise CAP_NET_ADMIN so we can make calls like `iptables`, `ip ...`
  let caps = rt::ext::capget()?;
  resources::caps_add(&caps.inheritable, rt::ext::cap::NET_ADMIN);
  rt::ext::capset(caps)?;
  errors::ext::swallow("[namespace/pasta] raise CAP_NET_ADMIN to configure interface", rt::ext::cap_ambient_raise(rt::ext::cap::NET_ADMIN));

  // forward dns to the desired endpoint
  let dnsdest = fmt::asprintf("{}:53", net.dns);
  defer free(dnsdest);
  let rc = ps::shellvpe_or_default(
    config::IPTABLES,
    "iptables",
    [
      "iptables",
      "-A", "OUTPUT",
      "-t", "nat",
      "-p", "udp",
      "--dport", "53",
      "-m", "iprange",
      "--dst-range", "127.0.0.1-127.0.0.255",
      "-j", "DNAT",
      "--to-destination", dnsdest,
    ],
    os::getenvs(),
  )?;
  log::printfln("[namespace/pasta] iptables exited {}", rc.status);

  // remove the loopback routing, else iptables-based DNS forwarding doesn't work.
  // the loopback interface is currently down; pasta will set it up, and when it
  // transitions from down to up it gets default addrs (127.0.0.1/8).
  // therefore, set it up *now*, and delete the addrs, and then since it's
  // already up they won't re-appear when we exec pasta.

  let rc = ps::shellvpe_or_default(
    config::IP,
    "ip",
    [
      "ip",
      "link",
      "set", "lo", "up",
    ],
    os::getenvs(),
  )?;
  log::printfln("[namespace/pasta] 'ip link set lo up' exited {}", rc.status);

  let rc = ps::shellvpe_or_default(
    config::IP,
    "ip",
    [
      "ip",
      "addr",
      "del", "127.0.0.1/8",
      "dev", "lo",
    ],
    os::getenvs(),
  )?;
  log::printfln("[namespace/pasta] 'ip addr del ...' exited {}", rc.status);
};
