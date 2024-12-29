use errors::ext;
use log;
use fs;
use os;
use path;
use rt;
use rt::ext;
use strings;

// everything inside this struct is borrowed
type ns_ctx = struct {
  what: *ns_resources,
  old_fs: *fs::fs,
  new_fs: *fs::fs,
};

// reconfigures all the mounts so that after this call the only paths accessible
// are those reachable from the provided `paths`.
// N.B.: this function does NOT preserve the current working directory.
// N.B.: if asked to mount `/foo/bar`, and then `/foo`, the second mount will
//   obscure the first.
//   i don't know if this really matters anywhere (maybe `/` and `/proc`?),
//   `sanebox` behavior is to gather all paths, expand their symlinks,
//   and then only bind-mount the top-most path in the case of overlap.
fn isolate_paths(what: *ns_resources) void = {
  // allow new mounts to propagate from the parent namespace into the child
  // namespace, but not vice versa (this is a requirement to use pivot_root)
  errors::ext::check("[namespace] reconfigure / as MS_SLAVE", rt::ext::mount("/", "/", "", rt::ext::mount_flag::SLAVE | rt::ext::mount_flag::REC, null));

  // in order to mount ANY directory from the old root into the new root,
  // they have to be totally disparate. if we kept the old root at / and the new
  // root at /tmp, then we couldn't bind `/tmp`.
  //
  // 1. pivoting _anywhere_ allows us to put the old root at `old`.
  //   i use `/tmp` here, just because that's how bubblewrap does it.
  // 2. create a new rootfs at `new` and bind stuff into it.
  // 3. then pivot a 2nd time, into `new` (and drop `old` altogether)

  // errors::ext::check("[namespace] mount /tmp /tmp", rt::ext::mount("/tmp", "/tmp", "", rt::ext::mount_flag::BIND));
  errors::ext::check("[namespace] mount -t tmpfs tmpfs /tmp", rt::ext::mount("tmpfs", "/tmp", "tmpfs", rt::ext::mount_flag::NODEV | rt::ext::mount_flag::NOSUID, null));

  pivot_into("/tmp", "old");
  // now we have `/`, empty except for the old rootfs available at `/old`

  // prepare a new rootfs. it has to be its own mount (tmpfs), not just a dir.
  errors::ext::check("[namespace] mkdir new", rt::mkdir("new", 0o755));
  errors::ext::check("[namespace] mount -t tmpfs tmpfs new", rt::ext::mount("tmpfs", "new", "tmpfs", 0, null));
  // errors::ext::check("[namespace] mount -t tmpfs tmpfs new", rt::ext::mount("tmpfs", "new", "tmpfs", rt::ext::mount_flag::NODEV | rt::ext::mount_flag::NOSUID, null));
  // errors::ext::check("[namespace] mount -o rbind new new", rt::ext::mount("new", "new", "", rt::ext::mount_flag::BIND | rt::ext::mount_flag::REC, null));

  // bind the new `/` tmpfs also to `/unbacked`; this is entirely optional, to
  // aid with troubleshooting:
  // `/unbacked` is a shallow bind of `/`, so provides a view into which files
  // are backed only by RAM.
  // admins can debug unexpected RAM use by querying (from outside the sandbox):
  // - `for p in /proc/*; do if [ "$p" != /proc/self -a "$p" != /proc/thread-self -a -d "$p/root/unbacked" ]; then du -h "$p/root/unbacked"; fi; done | sort -h`
  errors::ext::check("[namespace] mkdir new/unbacked", rt::mkdir("new/unbacked", 0o755));
  errors::ext::check("[namespace] mount new new/unbacked",
    rt::ext::mount(
      "new",
      "new/unbacked",
      "",
      rt::ext::mount_flag::BIND,
      null,
    )
  );

  // try to mount a new /proc.
  // - this is "safe" because we're not doing anything
  //   the sandboxed program can't do. IOW, if this is unsafe, then the downstream
  //   sandbox is unsafe, since it can do this same thing.
  // - sandboxers like bwrap require a /proc, to query their own /proc/self/ns.
  //   so grant them that.
  //
  // this will fail if `--bunpen-keep-pid` is specified, in which case the user
  // may prefer to specify `--bunpen-path /proc` and bind-mount it instead.
  // - bind-mounting /proc exposes:
  //   - visibility to all /proc/$PID directories
  //     - can see all process's `cmdline`
  //     - can *not* see the `environ` of processes from a different user namespace
  //     - can *not* join the /proc/$PID/ns/* entries of processes from a different user namespace (IUUC)
  //   - /proc/sys *should* be namespace-aware
  //     e.g. /proc/sys/net should show entries _for the reader's_ net namespace, not the mount owner's
  //     but in practice there are namespacing bugs at least as recently as 2021:
  //     <https://github.com/opencontainers/runc/issues/2826#issuecomment-915683044>
  errors::ext::swallow("[namespace] mkdir new/proc", rt::mkdir("new/proc", 0o755));
  errors::ext::swallow("[namespace] mount /new/proc", rt::ext::mount(
    "proc", "new/proc", "proc", rt::ext::mount_flag::NOSUID | rt::ext::mount_flag::NOEXEC | rt::ext::mount_flag::NODEV, null
  ));

  // provide a new `/tmp` too.
  errors::ext::swallow("[namespace] mkdir new/tmp", rt::mkdir("new/tmp", 0o777));
  // it doesn't actually *need* to be its own fs, since `/` is already a tmpfs.
  // actually, keeping /tmp on the rootfs makes ram-usage debugging easier.
  // errors::ext::swallow("[namespace] mount -t tmpfs tmpfs new/tmp", rt::ext::mount("tmpfs", "new/tmp", "tmpfs", 0, null));

  // some apps (e.g. signal-desktop) require /dev/shm.
  // /dev/shm is an ordinary tmpfs.
  // bwrap has `/dev` be a tmpfs.
  // however, it seems we can just `mkdir` these and not explicitly mount `tmpfs` on them.
  log::println("[namespace] setting up /dev");
  errors::ext::swallow("[namespace] mkdir new/dev", rt::mkdir("new/dev", 0o755));
  // errors::ext::swallow("[namespace] mount -t tmpfs tmpfs new/dev", rt::ext::mount("tmpfs", "new/dev", "tmpfs", 0, null));
  errors::ext::swallow("[namespace] mkdir new/dev/shm", rt::mkdir("new/dev/shm", 0o777));
  // errors::ext::swallow("[namespace] mount -t tmpfs tmpfs new/dev/shm", rt::ext::mount("tmpfs", "new/dev/shm", "tmpfs", 0, null));

  // some apps (e.g. aerc) require /dev/pts.
  log::println("[namespace] setting up /dev/pts");
  errors::ext::swallow("[namespace] mkdir new/dev/pts", rt::mkdir("new/dev/pts", 0o755));
  errors::ext::swallow("[namespace] mount -t devpts devpts new/dev/pts", rt::ext::mount(
    "devpts",
    "new/dev/pts",
    "devpts",
    rt::ext::mount_flag::NOSUID | rt::ext::mount_flag::NOEXEC,
    // "newinstance" is borrowed from bwrap, and google turns up: <https://bugzilla.redhat.com/show_bug.cgi?id=501718>
    // it works with or without this flag, idk enough about the pty system to say.
    "newinstance,ptmxmode=0666,mode=620",
  ));
  // /dev/ptmx and /dev/pts/ptmx are supposed to be one and the same?
  // bwrap symlinks /dev/ptms -> /dev/pts/ptmx.
  // bind-mounting ought to be the same, but i suppose symlinks are less fragile when recursively namespacing
  errors::ext::swallow("[namespace] ln -s pts/ptmx new/dev/ptmx", fs::symlink(os::cwd, "pts/ptmx", "new/dev/ptmx"));

  // XXX: bwrap binds /dev/console, but i haven't had a need to yet.
  // fs::create(os::cwd, "new/dev/console", 0o444)!;
  // errors::ext::swallow("[namespace] mount old/dev/pts/0 new/dev/console", rt::ext::mount(
  //   "old/dev/pts/0",  //< TODO: don't hardcode `/dev/pts/0`, but use `ttyname`
  //   "new/dev/console",
  //   "",
  //   rt::ext::mount_flag::BIND | rt::ext::mount_flag::REC,
  //   null,
  // ));

  // bind all the user-requested paths from `old/$p` into `new/$p`.
  // use the `dirfd` abstraction so that paths meant for `old` can't crawl out
  // of that virtual fs.
  let old_fd = errors::ext::check_int(
    "namespace setup: open /old",
    rt::open("old", rt::O_RDONLY | rt::O_CLOEXEC, rt::RESOLVE_NO_SYMLINKS: uint)
  );
  let old_fs = os::dirfdopen(old_fd);
  defer(free(old_fs));
  let new_fd = errors::ext::check_int(
    "namespace setup: open /new",
    rt::open("new", rt::O_RDONLY | rt::O_CLOEXEC, rt::RESOLVE_NO_SYMLINKS: uint),
  );
  let new_fs = os::dirfdopen(new_fd);
  defer(free(new_fs));

  let ctx = ns_ctx {
    what = what,
    old_fs = old_fs,
    new_fs = new_fs,
  };

  for (let path .. what.paths) {
    errors::ext::swallow(
      "[namespace] unable to bind {}",
      bind_leaf(&ctx, &path),
      path::string(&path),
    );
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
fn bind_leaf(ctx: *ns_ctx, user_path: *path::buffer) (void | path::error) = {
  let path_str = path::string(user_path);
  log::printfln("[namespace] permit path: {}", path_str);

  let it = path::iter(user_path);
  let cur_path = path::init()?;
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
    cur_strpath = path::push(&cur_path, comp)?;

    if (cur_strpath == "proc" && !ctx.what.pid) {
      // if we're inside a PID space, don't bind-mount /proc entries from the
      // outer /proc mount as it confuses things like bwrap.
      log::printfln("[namespace] not binding proc path {}", path_str);
      return;
    };

    // hmm, should we swallow this, or raise?
    // seems unlikely we'll fail to bind one part of the path, but then
    // successfully bind the *next* part.
    errors::ext::swallow(
      "[namespace] unable to copy intermediate path {} of {}",
      bind_component(ctx, cur_strpath, path::iterrem(&it)),
      cur_strpath, path_str
    );
  };
};

fn bind_component(ctx: *ns_ctx, strpath: str, remaining: str) (void | fs::error | path::error | rt::errno) = {
  let new_exists = match (fs::stat(ctx.new_fs, strpath)) {
    case let e: fs::error => yield false; // hasn't been bound yet
    case let other: fs::filestat => yield true; // already created
  };
  let st = fs::stat(ctx.old_fs, strpath)?;

  if (fs::islink(st.mode)) {
    let linktext = fs::readlink(ctx.old_fs, strpath)?;
    if (!new_exists) {
      // we already made the link (but not necessarily what's *behind* it: maybe
      // we bind-mounted its directory, and still need to mount the underlying)
      log::printfln("[namespace/bind] ln new/{} -> {}", strpath, linktext);
      fs::symlink(ctx.new_fs, linktext, strpath)?;
    };

    // bind the real path (or, the "more real" path, in case there are
    // multiple layers of symlink).
    let target_path: path::buffer = if (path::abs(linktext)) {
      // foo/bar/baz/fnord with (bar -> /target)                  => `/target/baz/fnord`
      // foo/bar/baz/fnord with (fnord -> /target, remaining="")  => `/target`
      yield path::init(linktext, remaining)?;
    } else {
      // foo/bar/baz/fnord with (foo -> target)                   => `foo/target/bar/baz`
      // foo/bar/baz/fnord with (fnord -> target, remaining="")   => `foo/bar/baz/target`
      yield path::init(strpath, "..", linktext, remaining)?;
    };
    return bind_leaf(ctx, &target_path);
  } else if (fs::isdir(st.mode)) {
    // don't recreate the directory if it exists, but DO try to bind-mount it.
    //   we could have mounted something below it, and then discovered the need
    //   to mount more.
    if (!new_exists) {
      log::printfln("[namespace/bind] mkdir new/{}", strpath);
      fs::mkdir(ctx.new_fs, strpath, st.mode)?;
    };
  } else {  // file-like
    if (new_exists) return;  // we already bound the file
    if (remaining != "") {
      log::printfln("[namespace/bind] ignoring file where a non-terminal was expected: {}", strpath);
      return fs::wrongtype;
    };

    // TODO: tune options (optional parameter; default is fs::flag::TRUNC)
    log::printfln("[namespace/bind] touch new/{}", strpath);
    fs::create(ctx.new_fs, strpath, st.mode)?;
  };

  if (remaining != "")
    return;  // nothing more to do for this path element

  // and now, perform the actual bind mount:
  let old_pathbuf = path::init("old", strpath)?;
  let new_pathbuf = path::init("new", strpath)?;

  log::printfln("[namespace/bind] mount {} {}", path::string(&old_pathbuf), path::string(&new_pathbuf));
  rt::ext::mount(
    path::string(&old_pathbuf),
    path::string(&new_pathbuf),
    "",
    rt::ext::mount_flag::BIND | rt::ext::mount_flag::REC,
    null,
  )?;
};

// make `new_root` the new `/`, and optionally make the old root accessible
// at some directory (to be created) underneath it.
fn pivot_into(new_root: str, stash_old_root: (str|void) = void) void = {
  log::printfln("[namespace] pivot_root {}", new_root);
  errors::ext::check("[namespace] cd <new_root>", os::chdir(new_root));
  match (stash_old_root) {
    case let old: str =>
      log::printfln("[namespace] placing old root at {}", old);
      errors::ext::check("[namespace] mkdir <stash_old_root>", rt::mkdir(old, 0o755));
      errors::ext::check("[namespace] pivot_root . <stash_old_root>", rt::ext::pivot_root(".", old));
    case void =>
      errors::ext::check("[namespace] pivot_root . .", rt::ext::pivot_root(".", "."));
      // drop the old rootfs. weird idiom, but documented in `man 2 pivot_root`.
      errors::ext::check("[namespace] umount .", rt::umount2(".", rt::ext::umount_flag::MNT_DETACH));
  };
  errors::ext::check("[namespace] cd /", os::chdir("/"));
};

