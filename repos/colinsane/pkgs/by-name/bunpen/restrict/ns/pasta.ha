// vim: set shiftwidth=2 :

use config;
use errors;
use errors::ext;
use fmt;
use io;
use log;
use os;
use os::exec;
use restrict;
use rt;
use rt::ext;
use strings;
use unix;

fn setup_pasta(net: restrict::net_subset) void = {
  // `pasta PID [options]`: creates a device in the netns of PID.
  // ordering:
  // 1. fork  into (P, C1)
  // 2. child C1: enter netns, signal parent P.
  // 3. parent P: fork and spawn `pasta --pid /proc/fd/$N` (C2)
  //    then dumbly wait on child (C2) until completion
  // 4. child C1:: wait for `pasta` to signal readiness on fd `$N`
  //
  // after that, C1 can continue on & exec into the user code
  //
  // TODO: this currently lacks the synchronization described above.
  // it still generally _works_, but possible that some applications are flaky

  let (pipe_parent_rd, pipe_child_wr) = unix::pipe()!;
  log::printfln("[namespace/pasta]: forking: parent will launch pasta while child will exec user code");
  match (fork_and_die_with_parent()) {
    case let child_pid: os::exec::process =>
      io::close(pipe_child_wr)!;

      io::readall(pipe_parent_rd, &[0u8])!;
      errors::ext::check("setup_pasta: attach", attach_pasta(net, child_pid));
      errors::ext::check("setup_pasta: wait", wait_and_propagate(child_pid));

      io::close(pipe_parent_rd)!;

    case void =>
      io::close(pipe_parent_rd)!;

      errors::ext::check("namespace: unshare net", rt::ext::unshare(rt::ext::clone_flag::NEWNET));
      errors::ext::check("setup_pasta: config routing", config_routing_in_ns(net));

      // drop enough caps so that pasta has permissions to enter our new netns.
      // TODO: just set the desired caps here, and then don't try to do it again.
      let res = restrict::resources {
        caps = rt::ext::CAPS_NONE, net = restrict::net_all, ...
      };
      restrict::capability_restrict(&res);
      io::write(pipe_child_wr, [1])!;

      // TODO: race condition here, where the child immediately continues on even
      // though pasta hasn't created the device.
      io::close(pipe_child_wr)!;

    case let e: (os::exec::error | rt::errno) =>
      errors::ext::check("setup_pasta: fork", e);
  };
};

// spawn pasta as a separate process, and have it attach to the netns of the given pid.
fn attach_pasta(net: restrict::net_subset, child: os::exec::process) (void | os::exec::error | rt::errno) = {
  return match (fork_and_die_with_parent()?) {
    case let pasta_pid: os::exec::process => yield void;
    case void =>
      // pasta needs permissions to create a device in the netns (it apparently
      // won't raise those caps itself). TODO: reduce these resources!
      let res = restrict::resources {
        caps = rt::ext::CAPS_ALL, net = restrict::net_all, ...
      };
      restrict::capability_restrict(&res);

      let netns_path = fmt::asprintf("/proc/{}/ns/net", child: int);
      defer free(netns_path);

      // let notify_fd_path = fmt::asprintf("/proc/self/fd/{}", notify_fd);
      // log::printfln("[namespace/pasta] notify {}", notify_fd_path);
      // defer free(notify_fd_path);

      // TODO: append dns argument to `pasta`.
      let pasta_args = [
        "pasta",
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
        "--netns", netns_path,
        // "--pid", notify_fd_path,
      ];
      log::printfln("[namespace/pasta]: invoking pasta: {}", strings::join(" ", pasta_args...));
      yield rt::ext::execvpe_or_default(
        config::PASTA,
        "pasta",
        pasta_args,
        os::getenvs(),
      );
  };
};

fn config_routing_in_ns(net: restrict::net_subset) (void | os::exec::error | rt::errno) = {
  // raise CAP_NET_ADMIN so we can make calls like `iptables`, `ip ...`
  let caps = rt::ext::capget()?;
  restrict::caps_add(&caps.inheritable, rt::ext::cap::NET_ADMIN);
  rt::ext::capset(caps)?;
  errors::ext::swallow("[namespace/pasta] raise CAP_NET_ADMIN to configure interface", rt::ext::cap_ambient_raise(rt::ext::cap::NET_ADMIN));

  // forward dns to the desired endpoint
  let dnsdest = fmt::asprintf("{}:53", net.dns);
  defer free(dnsdest);
  let rc = shellvpe_or_default(
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

  let rc = shellvpe_or_default(
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

  let rc = shellvpe_or_default(
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
