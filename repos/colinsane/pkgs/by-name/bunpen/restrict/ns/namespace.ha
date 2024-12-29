// vim: set shiftwidth=2 :
use errors::ext;
use fmt;
use fs;
use io;
use log;
use os;
use path;
use ps;
use resources;
use rt;
use rt::ext;
use strings;
use unix;

export type ns_resources = struct {
  paths: []path::buffer,
  ipc: bool,
  net: bool,
  pid: bool,
  try_users: bool,
};

export fn namespace_restrict(what: *ns_resources) void = {
  // record the uid and gid of the initial namespace, so that we can re-map them
  // in the new ns.
  let uid = unix::getuid();
  let gid = unix::getgid();

  let want_unshared: rt::ext::clone_flags =
    rt::ext::clone_flag::NEWCGROUP |
    rt::ext::clone_flag::NEWIPC |
    rt::ext::clone_flag::NEWNET |
    rt::ext::clone_flag::NEWNS |
    rt::ext::clone_flag::NEWPID |
    rt::ext::clone_flag::NEWUSER |
    rt::ext::clone_flag::NEWUTS
  ;
  let unshared: rt::ext::clone_flags = 0;

  if (what.ipc) {
    log::println("[namespace] keeping ipc namespace");
    want_unshared &= ~rt::ext::clone_flag::NEWIPC;
  };

  if (what.net) {
    log::println("[namespace] keeping net namespace");
    want_unshared &= ~rt::ext::clone_flag::NEWNET;
  };

  if (what.pid) {
    log::println("[namespace] keeping pid namespace");
    want_unshared &= ~rt::ext::clone_flag::NEWPID;
  };

  if (what.try_users) {
    log::println("[namespace] keeping user namespace *if possible*");
    want_unshared &= ~rt::ext::clone_flag::NEWUSER;
    if (try_unshare(want_unshared)) {
      unshared |= want_unshared;
    } else {
      log::println("[namespace] failed to unshare w/o user namespace. raising CAP_SYS_ADMIN and trying again");

      let raise_caps = rt::ext::CAPS_NONE;
      resources::caps_add(&raise_caps, rt::ext::cap::SYS_ADMIN);
      if (try_unshare_with(want_unshared, raise_caps))
        unshared |= want_unshared;
    };
    // if we failed to unshare, then fall back to unsharing with CLONE_NEWUSER
    if ((want_unshared & unshared) != want_unshared) {
      log::println("[namespace] NOT keeping user namespace");
      want_unshared |= rt::ext::clone_flag::NEWUSER;
    };
  };

  if ((want_unshared & unshared) != want_unshared) {
    // fallback for when `try_users == true` and we failed,
    // or if `try_users` was false from the start.
    log::printfln("[namespace] unshare {}", want_unshared: u64);
    errors::ext::check("namespace: unshare", rt::ext::unshare(want_unshared));
    unshared |= want_unshared;
  };

  // before mounting anything, set up the uids and gids in this namespace.
  // without this, everything shows up as 65534 a.k.a. 'nobody' a.k.a. 'overflow',
  // and `mkdir` will return EOVERFLOW.
  // all this does is make it so that namespace operations under uid 1000 are
  // mapped to non-ns ops by the same user, and vice-versa
  if ((unshared & rt::ext::clone_flag::NEWUSER) == rt::ext::clone_flag::NEWUSER)
    write_id_maps(uid, gid);

  if ((unshared & rt::ext::clone_flag::NEWPID) == rt::ext::clone_flag::NEWPID) {
    // fork twice, and become:
    // - original process
    //   - PID 1 in the namespace
    //     - PID 2, which execs the user code
    //
    // the OP and PID1 stick around, mostly idle, merely forwarding posix
    // signals they receive down this stack, and forwarding exit status up the stack.
    //
    // this forking accomplishes two things:
    // 1. the first fork is the only way to enter the PID namespace.
    // 2. the second fork allows *all* signals to be sent to the user code.
    //    by default, PID1 in any namespace can only receive SIGTERM, SIGSTOP,
    //    and signals for which it's explicitly installed handlers.
    //    without the second fork, we would need messy and racy logic to
    //    determine which signals received by the OP (e.g. SIGKILL, SIGUSR1)
    //    should be handled by it v.s. relayed to the user code. the only way to
    //    determine if a signal was/will be handled seems to be to parse /proc/$CHILD/status.
    //    if signal forwarding is unimportant, this second fork can be safely removed.
    errors::ext::check("[namespace/fork] forking new PID 1", ps::fork_and_propagate());
    errors::ext::check("[namespace/fork] forking second time, child will become user process", ps::fork_and_propagate());
  };

  // isolate the mounts. we have to do this *after* forking into the new PID
  // space -- otherwise we lack permissions to mount a *new* /proc.
  // better isolation would be to setup the mount space *before* forking above,
  // and then mounting just /proc here, but that's complicated particularly by
  // the many circumstances in which we might want to mount *portions* of the
  // outside /proc over the new /proc.
  let pwd = strings::dup(os::getcwd());  // dup because API uses a static buffer
  defer(free(pwd));
  isolate_paths(what);
  // try to change to the old working directory;
  // this can fail if it's not within the sandbox.
  errors::ext::swallow("namespace: restore $PWD", os::chdir(pwd));
};

// try to `unshare(flags)`, return true on success
fn try_unshare(flags: rt::ext::clone_flags) bool = {
  return match (rt::ext::unshare(flags)) {
    case void =>
      log::println("[namespace] try_unshare successful");
      yield true;
    case let e: rt::errno =>
      errors::ext::swallow("[namespace] try_unshare", e);
      yield false;
  };
};

// raise capabilities, unshare, and then restore effective capabilities to as before.
// returns true if we unshared.
fn try_unshare_with(flags: rt::ext::clone_flags, caps: rt::ext::caps) bool = {
  let orig_caps = match (rt::ext::capget()) {
    case let c: rt::ext::caps_eip => yield c;
    case let err: rt::errno =>
      errors::ext::swallow("[namespace] raise caps: capget failed", err);
      return false;
  };

  let new_caps = orig_caps;
  resources::caps_add_caps(&new_caps.effective, caps);
  errors::ext::swallow("[namespace] raise caps", rt::ext::capset(new_caps));

  let unshared = try_unshare(flags);

  // if we unshared a user ns, the caps in that ns have no relation to the
  // original ns. but if we didn't unshare a user, or we failed the unshare,
  // then restore caps
  if (!unshared || (flags & rt::ext::clone_flag::NEWUSER) == 0) {
    errors::ext::check("[namespace] restore caps", rt::ext::capset(orig_caps));
  };

  return unshared;
};

// these id maps are writable *once*.
// - uid_map, gid_map: tell the kernel how uid's from the parent namespace
//                     should be presented to members of the current namespace,
//                     AND vice-versa.
//   - each line has the format:
//     `ID-inside-ns   ID-outside-ns   number-of-ids-to-map`
//   - multiple lines are allowed
//   - it seems as those ID-outside-ns can only be an ID controlled by the user
//     that created the namespace (else: EPERM), which would make sense if this is a bidirectional mapping
fn write_id_maps(uid: unix::uid, gid: unix::gid) void = {
  errors::ext::swallow("[namespace] write /proc/self/uid_map", write_id_map("/proc/self/uid_map", uid));
  errors::ext::swallow("[namespace] write /proc/self/setgroups", write_setgroups());
  errors::ext::swallow("[namespace] write /proc/self/gid_map", write_id_map("/proc/self/gid_map", gid));
};

fn write_id_map(which: str, id: uint) (void | rt::errno | io::error) = {
  let id_fd = rt::open(which, rt::O_RDWR | rt::O_CLOEXEC, 0)?;
  let id_buf: [4096]u8 = [0...];
  let id_str = fmt::bsprintf(id_buf, "{0} {0} 1\n", id);
  io::write(id_fd, strings::toutf8(id_str))?;
};

fn write_setgroups() (void | rt::errno | io::error) = {
  let setgroups_fd = rt::open("/proc/self/setgroups", rt::O_RDWR | rt::O_CLOEXEC, 0)?;
  io::write(setgroups_fd, &['d': u8, 'e', 'n', 'y', '\n', 0])?;
};
