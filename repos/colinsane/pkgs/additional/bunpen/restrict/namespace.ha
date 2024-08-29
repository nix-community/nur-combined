// vim: set shiftwidth=2 :
use fmt;
use fs;
use io;
use log;
use os;
use os::exec;
use path;
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
    rtext::CLONE_NEWPID |
    rtext::CLONE_NEWUSER |
    rtext::CLONE_NEWUTS
  ;
  if (what.net) {
    log::println("[namespace] keeping net namespace");
    what_to_unshare &= ~rtext::CLONE_NEWNET;
  };
  if (what.pid) {
    log::println("[namespace] keeping pid namespace");
    what_to_unshare &= ~rtext::CLONE_NEWPID;
  } else {
    log::println("TODO: namespacing without --bunpen-keep-pid is unsupported");
    what_to_unshare &= ~rtext::CLONE_NEWPID;
  };

  log::printfln("[namespace] unshare {}", what_to_unshare);
  rtext::unshare(what_to_unshare)!;

  if (!what.pid) {
    // fork and become:
    // - PID 1 in the namespace, which then launches the sandboxed program
    // - a dummy process which waits for the above to exit and propagates its status
    // TODO: it be possible after forking for the parent to `setns` to the
    // child, and then have the child exit. this would require only a single
    // long-run process instead of two (this process would need to explicitly
    // make itself a reaper since it'll be PID 2).
    rtext::check_error("[namespace/fork] forking new PID 1", fork_and_propagate());
  };

  // before mounting anything, set up the uids and gids in this namespace.
  // without this, everything shows up as 65534 a.k.a. 'nobody' a.k.a. 'overflow',
  // and `mkdir` will return EOVERFLOW.
  // all this does is make it so that namespace operations under uid 1000 are
  // mapped to non-ns ops by the same user, and vice-versa
  write_uid_map(uid, gid);

  let pwd = strings::dup(os::getcwd());  // dup because API uses a static buffer
  defer(free(pwd));
  isolate_paths(what.paths);
  // try to change to the old working directory;
  // this can fail if it's not within the sandbox.
  rtext::swallow_error("namespace: restore $PWD", os::chdir(pwd));

  // TODO: CLONE_NEWPID (might not work without forking to also become reaper)
};

// fork and:
// - in the child: continue execution as normal
// - in the parent: wait for the child, then propagate its exit status
fn fork_and_propagate() (void | os::exec::error) = {
  match (os::exec::fork()?) {
    case let child_pid: os::exec::process =>
      let status = os::exec::wait(&child_pid)?;
      log::printfln("[namespace/fork] child exited with {}", status.status);
      os::exit(status.status);  // propagate exit code
    case => log::println("[namespace/fork] continuing as child");
  };
};

// reconfigures all the mounts so that after this call the only paths accessible
// are those reachable from the provided `paths`.
// N.B.: this function does NOT preserve the current working directory
fn isolate_paths(paths: []path::buffer) void = {
  // allow new mounts to propagate from the parent namespace into the child
  // namespace, but not vice versa:
  rtext::check_error("[namespace] reconfigure / as MS_SLAVE", rtext::mount("/", "/", "", rtext::MS_SLAVE | rtext::MS_REC, null));

  // in order to mount ANY directory from the old root into the new root,
  // they have to be totally disparate. if we kept the old root at / and the new
  // root at /tmp, then we couldn't bind `/tmp`.
  //
  // 1. pivoting _anywhere_ allows us to put the old root at `old`.
  //   i use `/tmp` here, just because that's how bubblewrap does it.
  // 2. create a new rootfs at `new` and bind stuff into it.
  // 3. then pivot a 2nd time, into `new` (and drop `old` altogether)

  rtext::check_error("[namespace] mount -t tmpfs tmpfs /tmp", rtext::mount("tmpfs", "/tmp", "tmpfs", 0, null));

  pivot_into("/tmp", "old");
  // now we have `/`, empty except for the old rootfs available at `/old`

  // prepare a new rootfs. it has to be its own mount (tmpfs), not just a dir.
  rtext::check_error("[namespace] mkdir new", rt::mkdir("new", 0o755));
  rtext::check_error("[namespace] mount -t tmpfs tmpfs new", rtext::mount("tmpfs", "new", "tmpfs", 0, null));

  // bind all the user-requested paths from `old/$p` into `new/$p`.
  // use the `dirfd` abstraction so that paths meant for `old` can't crawl out
  // of that virtual fs.
  let old_fd = rt::open("old", rt::O_RDONLY | rt::O_CLOEXEC, rt::RESOLVE_NO_SYMLINKS: uint)!;
  let old_fs = os::dirfdopen(old_fd);
  defer(free(old_fs));
  let new_fd = rt::open("new", rt::O_RDONLY | rt::O_CLOEXEC, rt::RESOLVE_NO_SYMLINKS: uint)!;
  let new_fs = os::dirfdopen(new_fd);
  defer(free(new_fs));

  for (let path .. paths) {
    bind_leaf(old_fs, new_fs, &path);
  };

  // pivot into the new rootfs
  pivot_into("new");

  log::println("namespace restrictions activated");
};

// walk from root to `p`, creating any ancestors necessary and then binding the
// leaf from the old fs into the new fs.
//
// cases handled:
// - [x] `p` is already present in the new fs. no-op.
// - [x] `p` doesn't exist in the old fs. no-op.
// - [x] ancestors of `p` are all ordinary directories in the old fs:
//       corresponding directories will be created in the new fs.
//       mountpoints are treated as directories for this case.
// - [x] ancestors of `p` are symlinks, such that `p != realpath(p)`.
//       corresponding symlinks will be created in the new fs, as well as
//       exactly as many underlying directories necessary to bind `p`.
// - [x] `p` itself is a symlink in the old fs, rather than a file/directory.
//       an equivalent symlink will be created, and then its target will be
//       bound as per the logic described above.
// - `path::buffer` is canonicalized at creation, so we don't have to worry
//   about `./exists/does-not/../also-exists` not working.
//
// failure modes handled:
// - [x] path is too long  => does not create the leaf *nor any ancestors*.
// - [x] canonical path points outside the fs (e.g. `..`, or `../new/proc`).
//       does not create the leaf *nor any of its ancestors* at/after the `..`.
fn bind_leaf(old_fs: *fs::fs, new_fs: *fs::fs, user_path: *path::buffer) void = {
  let path_str = path::string(user_path);
  log::printfln("[namespace] permit path: {}", path_str);

  let it = path::iter(user_path);
  let cur_path = path::init()!;
  let cur_strpath = "";
  for (let comp => path::nextiter(&it)) {
    if (comp == "..") {
      log::printfln("[namespace] not binding external path {} (of {})", cur_strpath, path_str);
      return;
    };
    if (path::abs(comp)) {
      // dirfd doesn't do well will absolute paths.
      comp = strings::sub(comp, 1, strings::end);
    };
    cur_strpath = match (path::push(&cur_path, comp)) {
      case let e: path::error =>
        log::printfln("[namespace] unable to construct intermediate path for binding {} / {}: {}", cur_strpath, comp, path::strerror(e));
        return;
      case let other: str =>
        yield other;
    };

    match (bind_component(old_fs, new_fs, cur_strpath, path::iterrem(&it))) {
      case let e: fs::error =>
        log::printfln("[namespace] unable to copy intermediate path {} of {}: {}", cur_strpath, path_str, fs::strerror(e));
        return;
      case let e: path::error =>
        log::printfln("[namespace] unable to copy intermediate path {} of {}: {}", cur_strpath, path_str, path::strerror(e));
        return;
      case void => void;
    };
  };

  // and now, perform the actual bind mount:
  // XXX: if the thing being mounted over is a symlink, the `mount` syscall will FAIL
  // (and be swallowed). that's GOOD; we don't want to mount over a symlink.
  let old_pathbuf = match (path::init("old", path_str)) {
    case let e: path::error =>
      log::printfln("[namespace] unable to construct old path for binding {}: {}", path_str, path::strerror(e));
      return;
    case let other: path::buffer =>
      yield other;
  };
  let new_pathbuf = match (path::init("new", path_str)) {
    case let e: path::error =>
      log::printfln("[namespace] unable to construct new path for binding {}: {}", path_str, path::strerror(e));
      return;
    case let other: path::buffer =>
      yield other;
  };
  log::printfln("[namespace/bind] mount {} {}", path::string(&old_pathbuf), path::string(&new_pathbuf));
  rtext::swallow_error("[namespace/bind] bind_leaf: mount", rtext::mount(
    path::string(&old_pathbuf), path::string(&new_pathbuf), "", rtext::MS_BIND | rtext::MS_REC, null
  ));
};

fn bind_component(old_fs: *fs::fs, new_fs: *fs::fs, strpath: str, remaining: str) (void | fs::error | path::error) = {
  match (fs::stat(new_fs, strpath)) {
    case let e: fs::error => void;
    case let other: fs::filestat => return; // already created
  };
  let st = fs::stat(old_fs, strpath)?;
  // if (st.mode == mode_new) {
  //   return; // already created
  // };

  if (fs::islink(st.mode)) {
    let linktext = fs::readlink(old_fs, strpath)?;
    log::printfln("[namespace/bind] ln new/{} -> {}", strpath, linktext);
    fs::symlink(new_fs, linktext, strpath)?;
    if (remaining != "") {
      // bind the real path (or, the "more real" path, in case there are
      // multiple layers of symlink).
      let target_path: path::buffer = if (path::abs(linktext)) {
        // foo/bar/baz/fnord with bar -> /target  => `/target/baz/fnord`
        yield path::init(linktext, remaining)?;
      } else {
        // foo/bar/baz/fnord with foo -> target  => `foo/target/bar/baz`
        yield path::init(strpath, "..", linktext, remaining)?;
      };
      bind_leaf(old_fs, new_fs, &target_path);
    };
  } else if (fs::isdir(st.mode)) {
    log::printfln("[namespace/bind] mkdir new/{}", strpath);
    fs::mkdir(new_fs, strpath, st.mode)?;
  } else {  // file-like
    if (remaining != "") {
      log::printfln("[namespace/bind] ignoring file where a non-terminal was expected: {}", strpath);
      return fs::wrongtype;
    };

    // TODO: tune options (optional parameter; default is fs::flag::TRUNC)
    log::printfln("[namespace/bind] touch new/{}", strpath);
    fs::create(new_fs, strpath, st.mode)?;
  };
};

// make `new_root` the new `/`, and optionally make the old root accessible
// at some directory (to be created) underneath it.
fn pivot_into(new_root: str, stash_old_root: (str|void) = void) void = {
  log::printfln("[namespace] pivot_root {}", new_root);
  rtext::check_error("[namespace] cd <new_root>", os::chdir(new_root));
  match (stash_old_root) {
    case let old: str =>
      rtext::check_error("[namespace] mkdir <stash_old_root>", rt::mkdir(old, 0o755));
      rtext::check_error("[namespace] pivot_root . <stash_old_root>", rtext::pivot_root(".", old));
    case void =>
      rtext::check_error("[namespace] pivot_root . .", rtext::pivot_root(".", "."));
      // drop the old rootfs. weird idiom, but documented in `man 2 pivot_root`.
      rtext::check_error("[namespace] umount .", rt::umount2(".", rtext::MNT_DETACH));
  };
  rtext::check_error("[namespace] cd /", os::chdir("/"));
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
