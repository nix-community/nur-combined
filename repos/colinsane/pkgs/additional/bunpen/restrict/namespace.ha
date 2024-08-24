// vim: set shiftwidth=2 :
use fmt;
use fs;
use io;
use log;
use os;
use rt;
use rtext;
use strings;
use unix;

export fn namespace_restrict(what: *resources) void = {
  // record the uid and gid of the initial namespace, so that we can re-map them
  // in the new ns.
  let uid = unix::getuid();
  let gid = unix::getgid();

  // unshare as much as possible, by default:
  let what_to_unshare =
    rtext::CLONE_NEWCGROUP |
    rtext::CLONE_NEWIPC |
    rtext::CLONE_NEWNET |
    rtext::CLONE_NEWNS |
    rtext::CLONE_NEWUSER |
    rtext::CLONE_NEWUTS
  ;
  if (what.net) {
    log::println("namespace: permit net");
    what_to_unshare &= ~rtext::CLONE_NEWNET;
  };

  log::printfln("namespace: unshare {}", what_to_unshare);
  rtext::unshare(what_to_unshare)!;

  // before mounting anything, set up the uids and gids in this namespace.
  // without this, everything shows up as 65534 a.k.a. 'nobody' a.k.a. 'overflow',
  // and `mkdir` will return EOVERFLOW.
  // all this does is make it so that namespace operations under uid 1000 are
  // mapped to non-ns ops by the same user, and vice-versa
  write_uid_map(uid, gid);

  rt::mount("tmpfs", "/tmp", &['t': u8, 'm', 'p', 'f', 's', 0]: *const u8, rtext::MS_NODEV | rtext::MS_NOSUID, null)!;

  // chroot to `/tmp`, with the old root being placed at `/tmp/oldroot` (i.e. /oldroot)
  check_error("cd /tmp", os::chdir("/tmp"));
  check_error("mkdir /tmp/oldroot", rt::mkdir("oldroot", 0o755));
  rtext::pivot_root("/tmp", "oldroot")!;
  check_error("cd /", os::chdir("/"));

  // chroot back into `/oldroot`.
  // TODO: we should rather chroot into `/newroot`, after mounting everything
  // there. this is just a proof-of-concept
  check_error("cd /oldroot", os::chdir("/oldroot"));
  rtext::pivot_root("/oldroot", ".")!;
  check_error("cd /", os::chdir("/"));

  // TODO: CLONE_NEWPID (might not work without forking to also become reaper)
};

fn check_error(op: str, c: (void | fs::error | rt::errno)) void = {
  match (c) {
    case void => void;
    case let e: rt::errno => log::fatalf("{}: {}: {}", op, rt::errname(e), rt::strerror(e));
    case let e: fs::error => log::fatalf("{}: {}", op, fs::strerror(e));
  };
};

fn write_uid_map(uid: unix::uid, gid: unix::gid) void = {
  let uid_fd = rt::open("/proc/self/uid_map", rt::O_RDWR | rt::O_CLOEXEC, 0)!;
  let uid_buf: [4096]u8 = [0...];
  let uid_str = fmt::bsprintf(uid_buf, "{0} {0} 1\n", uid: uint);
  io::write(uid_fd, strings::toutf8(uid_str))!;

  let setgroups_fd = rt::open("/proc/self/setgroups", rt::O_RDWR | rt::O_CLOEXEC, 0)!;
  io::write(setgroups_fd, &['d': u8, 'e', 'n', 'y', '\n', 0])!;

  let gid_fd = rt::open("/proc/self/gid_map", rt::O_RDWR | rt::O_CLOEXEC, 0)!;
  let gid_buf: [4096]u8 = [0...];
  let gid_str = fmt::bsprintf(gid_buf, "{0} {0} 1\n", gid: uint);
  io::write(gid_fd, strings::toutf8(gid_str))!;
};
