// vim: set shiftwidth=2 :
use fmt;
use fs;
use io;
use log;
use os;
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

  // allow new mounts to propagate from the parent namespace into the child
  // namespace, but not vice versa:
  rtext::check_error("reconfigure / as MS_SLAVE", rtext::mount("/", "/", "", rtext::MS_SLAVE | rtext::MS_REC, null));

  // in order to mount ANY directory from the old root into the new root,
  // they have to be totally disparate. if we kept the old root at / and the new
  // root at /tmp, then we couldn't bind `/tmp`.
  //
  // 1. pivoting _anywhere_ allows us to put the old root at `old`.
  //   i use `/tmp` here, just because that's how bubblewrap does it.
  // 2. create a new rootfs at `new` and bind stuff into it.
  // 3. then pivot a 2nd time, into `new` (and drop `old` altogether)

  rtext::check_error("mount -t tmpfs tmpfs /tmp", rtext::mount("tmpfs", "/tmp", "tmpfs", 0, null));

  pivot_into("/tmp", "old");
  // now we have `/`, empty except for the old rootfs available at `/old`

  // prepare a new rootfs. it has to be its own mount (tmpfs), not just a dir.
  rtext::check_error("mkdir new", rt::mkdir("new", 0o755));
  rtext::check_error("mount -t tmpfs tmpfs new", rtext::mount("tmpfs", "new", "tmpfs", 0, null));

  {
    // bind all the user-requested paths from `old/$p` into `new/$p`.
    // use the `dirfd` abstraction so that paths meant for `old` can't crawl out
    // of that virtual fs.
    let old_fd = rt::open("old", rt::O_RDONLY | rt::O_CLOEXEC, rt::RESOLVE_NO_SYMLINKS: uint)!;
    let old_fs = os::dirfdopen(old_fd);
    defer(free(old_fs));
    let new_fd = rt::open("new", rt::O_RDONLY | rt::O_CLOEXEC, rt::RESOLVE_NO_SYMLINKS: uint)!;
    let new_fs = os::dirfdopen(new_fd);
    defer(free(new_fs));

    for (let path .. what.paths) {
      bind_leaf(old_fs, new_fs, path);
    };
  };

  // pivot into the new rootfs
  pivot_into("new");

  // TODO: `chdir` back to the original dir we were executed from

  // TODO: CLONE_NEWPID (might not work without forking to also become reaper)
};

// walk from root to `p`, creating any ancestors necessary and then binding the
// leaf from the old fs into the new fs.
//
// cases handled:
// - [x] `p` is already present in the new fs. no-op.
// - [x] ancestors of `p` are all ordinary directories in the old fs:
//       corresponding directories will be created in the new fs.
//       mountpoints are treated as directories for this case.
// - [ ] ancestors of `p` are symlinks, such that `p != realpath(p)`.
//       corresponding symlinks will be created in the new fs, as well as
//       exactly as many underlying directories necessary to bind `p`.
// - [ ] `p` itself is a symlink in the old fs, rather than a file/directory.
//       an equivalent symlink will be created, and then its target will be
//       bound as per the logic described above.
// - [x] `p` is not canonicalized. it will be canonicalized *before* any of the
//       above processing.
//
// failure modes handled:
// - [x] path is too long  => does not create the leaf *nor any ancestors*.
// - [x] canonical path points outside the fs (e.g. `..`, or `../new/proc`).
//       does not create the leaf *nor any of its ancestors* at/after the `..`.
fn bind_leaf(old_fs: *fs::fs, new_fs: *fs::fs, user_path: str) void = {
  log::printfln("namespace: permit path: {}", user_path);
  // parse the path, which has the effect also of canonicalizing it.
  // returns error if the path is too long.
  // may point to `.` or `../`
  let p = match (path::init(user_path)) {
    case let e: path::error =>
      // should happen only if the path is absurdly long. swallow it and return.
      log::printfln("unable to bind {}: {}", user_path, path::strerror(e));
      return;
    case let other: path::buffer =>
      yield other;
  };

  let it = path::iter(&p);
  let cur_path = path::init()!;
  let cur_strpath = "";
  for (let comp => path::nextiter(&it)) {
    if (comp == "..") {
      log::printfln("not binding external path {} (of {})", cur_strpath, user_path);
      return;
    };
    if (len(comp) >= 1 && strings::sub(comp, 0, 1) == "/") {
      // dirfd doesn't do well will absolute paths.
      comp = strings::sub(comp, 1, strings::end);
    };
    cur_strpath = match (path::push(&cur_path, comp)) {
      case let e: path::error =>
        log::printfln("unable to construct intermediate path for binding {} / {}: {}", cur_strpath, comp, path::strerror(e));
        return;
      case let other: str =>
        yield other;
    };

    match (bind_component(old_fs, new_fs, cur_strpath)) {
      case let e: fs::error =>
        log::printfln("unable to copy intermediate path {} of {}: {}", cur_strpath, user_path, fs::strerror(e));
        return;
      case void => void;
    };
  };

  // and now, perform the actual bind:
  let old_path = p;
  let new_path = p;
  let old_strpath = match (path::prepend(&old_path, "old")) {
    case let e: path::error =>
      log::printfln("unable to construct old path for binding {}: {}", user_path, path::strerror(e));
      return;
    case let other: str =>
      yield other;
  };
  let new_strpath = match (path::prepend(&new_path, "new")) {
    case let e: path::error =>
      log::printfln("unable to construct new path for binding {}: {}", user_path, path::strerror(e));
      return;
    case let other: str =>
      yield other;
  };
  rtext::swallow_error("bind_leaf: mount", rtext::mount(old_strpath, new_strpath, "", rtext::MS_BIND | rtext::MS_REC, null));
};

fn bind_component(old_fs: *fs::fs, new_fs: *fs::fs, strpath: str) (void | fs::error) = {
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
    fs::symlink(new_fs, linktext, strpath)?;
    // TODO: lots of edge cases with symlinks i need to flesh out here.
  } else if (fs::isdir(st.mode)) {
    fs::mkdir(new_fs, strpath, st.mode)?;
  } else {
    // TODO: tune options (optional parameter; default is fs::flag::TRUNC)
    fs::create(new_fs, strpath, st.mode)?;
  };
};

// make `new_root` the new `/`, and optionally make the old root accessible
// at some directory (to be created) underneath it.
fn pivot_into(new_root: str, stash_old_root: (str|void) = void) void = {
  log::printfln("namespace: pivot_root {}", new_root);
  rtext::check_error("cd <new_root>", os::chdir(new_root));
  match (stash_old_root) {
    case let old: str =>
      rtext::check_error("mkdir <stash_old_root>", rt::mkdir(old, 0o755));
      rtext::check_error("pivot_root . <stash_old_root>", rtext::pivot_root(".", old));
    case void =>
      rtext::check_error("pivot_root . .", rtext::pivot_root(".", "."));
      // drop the old rootfs. weird idiom, but documented in `man 2 pivot_root`.
      rtext::check_error("umount .", rt::umount2(".", rtext::MNT_DETACH));
  };
  rtext::check_error("cd /", os::chdir("/"));
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
