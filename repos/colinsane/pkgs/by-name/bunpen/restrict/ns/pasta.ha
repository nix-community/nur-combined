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
  // 3. parent P: fork and spawn `pasta --pid /dev/fd/$N` (C2)
  //    then dumbly wait on child (C2) until completion
  // 4. child C1:: wait for `pasta` to signal readiness on fd `$N`
  //
  // after that, C1 can continue on & exec into the user code

  let (pipe_parent_rd, pipe_child_wr) = unix::pipe()!;
  let (pipe_child_rd, pipe_parent_wr) = unix::pipe()!;
  log::printfln("[namespace/pasta]: forking: parent will launch pasta while child will exec user code");
  match (fork_and_die_with_parent()) {
    case let child_pid: os::exec::process =>
      // close the pipe ends which aren't ours
      io::close(pipe_child_wr)!;
      io::close(pipe_child_rd)!;

      // wait for the child to signal that it's ready for us to attach pasta.
      io::readall(pipe_parent_rd, &[0u8])!;
      errors::ext::check("setup_pasta: attach", attach_pasta(net, child_pid));

      // let the child know its environment is configured
      io::write(pipe_parent_wr, [1])!;

      errors::ext::check("setup_pasta: wait", wait_and_propagate(child_pid));

      // cleanup: we're done with the pipes
      io::close(pipe_parent_wr)!;
      io::close(pipe_parent_rd)!;

    case void =>
      // close the pipe ends which aren't ours
      io::close(pipe_parent_wr)!;
      io::close(pipe_parent_rd)!;

      errors::ext::check("namespace: unshare net", rt::ext::unshare(rt::ext::clone_flag::NEWNET));
      errors::ext::check("setup_pasta: config routing", config_routing_in_ns(net));

      // drop enough caps so that pasta has permissions to enter our new netns.
      // TODO: just set the desired caps here, and then don't try to do it again.
      let res = restrict::resources {
        caps = rt::ext::CAPS_NONE, net = restrict::net_all, ...
      };
      restrict::capability_restrict(&res);
      // let the parent know we're ready for pasta to attach to us
      io::write(pipe_child_wr, [1])!;

      // wait for the parent to attach pasta
      io::readall(pipe_child_rd, &[0u8])!;

      // cleanup: we're done with the pipes
      io::close(pipe_child_wr)!;
      io::close(pipe_child_rd)!;

    case let e: (os::exec::error | rt::errno) =>
      errors::ext::check("setup_pasta: fork", e);
  };
};

// spawn pasta as a separate process, and have it attach to the netns of the given pid.
fn attach_pasta(net: restrict::net_subset, child: os::exec::process) (void | os::exec::error | rt::errno) = {
  // pipe is used by child pasta process to notify parent process once ready
  let (pipe_parent_rd, pipe_child_wr) = unix::pipe(unix::pipe_flag::NOCLOEXEC)!;
  return match (fork_and_die_with_parent()?) {
    case let pasta_pid: os::exec::process =>
      // close the side of the pipe that's not ours:
      io::close(pipe_child_wr)!;

      // wait for pasta to signal readiness.
      // it does this by writing its pid (followed by newline) to a file.
      let pasta_pid: [32]u8 = [0...];
      io::read(pipe_parent_rd, &pasta_pid)!;

      log::printfln(
        "[namespace/pasta] pasta signalled readiness as pid {}: continuing",
        strings::fromutf8_unsafe(pasta_pid),
      );

      // cleanup: we're done with the pipe
      io::close(pipe_parent_rd)!;

      yield void;
    case void =>
      // close the side of the pipe that's not ours:
      io::close(pipe_parent_rd)!;

      // move the notification pipe to be one of the special fd's which *don't*
      // get closed on exec (e.g. /dev/fd/0, stdin).
      // this *shouldn't* be necessary: the pipe was created NOCLOEXEC;
      // but maybe pasta is doing some security measure like clearing all open fd's on exec.
      rt::dup2(pipe_child_wr, 0)!;
      io::close(pipe_child_wr)!;
      let notify_fd_path = "/dev/fd/0";

      // pasta needs permissions to create a device in the netns (it apparently
      // won't raise those caps itself). TODO: reduce these resources!
      let res = restrict::resources {
        caps = rt::ext::CAPS_ALL, net = restrict::net_all, ...
      };
      restrict::capability_restrict(&res);

      let netns_path = fmt::asprintf("/proc/{}/ns/net", child: int);
      defer free(netns_path);

      let pasta_args = [
        "pasta",
        "--quiet",  //< don't print MAC/DHCP/DNS values  (TODO: enable these for BUNPEN_DEBUG>=1)
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
        "--pid", notify_fd_path,
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
