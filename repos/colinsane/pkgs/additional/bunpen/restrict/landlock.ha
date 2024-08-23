// vim: set shiftwidth=2 :
use log;
use os;
use rt;
use rtext;

fn access_fs_roughly_read() u64 = return
  rtext::LANDLOCK_ACCESS_FS_EXECUTE |
  rtext::LANDLOCK_ACCESS_FS_READ_FILE |
  rtext::LANDLOCK_ACCESS_FS_READ_DIR
;
fn access_fs_roughly_write() u64 = return
  rtext::LANDLOCK_ACCESS_FS_WRITE_FILE |
  rtext::LANDLOCK_ACCESS_FS_REMOVE_DIR |
  rtext::LANDLOCK_ACCESS_FS_REMOVE_FILE |
  rtext::LANDLOCK_ACCESS_FS_MAKE_CHAR |
  rtext::LANDLOCK_ACCESS_FS_MAKE_DIR |
  rtext::LANDLOCK_ACCESS_FS_MAKE_REG |
  rtext::LANDLOCK_ACCESS_FS_MAKE_SOCK |
  rtext::LANDLOCK_ACCESS_FS_MAKE_FIFO |
  rtext::LANDLOCK_ACCESS_FS_MAKE_BLOCK |
  rtext::LANDLOCK_ACCESS_FS_MAKE_SYM |
  rtext::LANDLOCK_ACCESS_FS_REFER |
  rtext::LANDLOCK_ACCESS_FS_TRUNCATE |
  rtext::LANDLOCK_ACCESS_FS_IOCTL_DEV
;
fn access_fs_roughly_rw() u64 = return access_fs_roughly_read() | access_fs_roughly_write();
fn access_file() u64 = return
  rtext::LANDLOCK_ACCESS_FS_EXECUTE |
  rtext::LANDLOCK_ACCESS_FS_WRITE_FILE |
  rtext::LANDLOCK_ACCESS_FS_READ_FILE |
  rtext::LANDLOCK_ACCESS_FS_TRUNCATE |
  rtext::LANDLOCK_ACCESS_FS_IOCTL_DEV
;

fn allow_path_fd(ruleset_fd: u64, path_fd: i32) (rt::errno | u64) = {
  let access = access_fs_roughly_rw();
  let statbuf = rt::st { ... };
  rt::fstat(path_fd, &statbuf)?;

  if (statbuf.mode & rt::S_IFDIR == 0) {
    // not a directory: remove all access modes which are only sensible for
    // directories, else landlock will fail.
    access = access & access_file();
  };

  return rtext::landlock_add_rule(ruleset_fd, &rtext::landlock_path_beneath_attr {
    allowed_access = access,
    parent_fd = path_fd,
  });
};

export fn landlock_restrict(what: *resources) void = {
  let abi = rtext::landlock_create_ruleset(null, rtext::LANDLOCK_CREATE_RULESET_VERSION)!;
  log::printfln("found landlock version {}", abi);

  // determine the access modes we can ask this kernel to restrict on:
  let ruleset_attr = rtext::landlock_ruleset_attr {
    handled_access_fs = access_fs_roughly_rw(),
    handled_access_net = rtext::LANDLOCK_ACCESS_NET_BIND_TCP | rtext::LANDLOCK_ACCESS_NET_CONNECT_TCP,
  };
  if (abi == 1) {
    ruleset_attr.handled_access_fs &= ~rtext::LANDLOCK_ACCESS_FS_REFER;
  };
  if (abi <= 2) {
    ruleset_attr.handled_access_fs &= ~rtext::LANDLOCK_ACCESS_FS_TRUNCATE;
  };
  if (abi <= 3) {
    ruleset_attr.handled_access_net &= ~(rtext::LANDLOCK_ACCESS_NET_BIND_TCP | rtext::LANDLOCK_ACCESS_NET_CONNECT_TCP);
  };
  if (abi <= 4) {
    ruleset_attr.handled_access_fs &= ~rtext::LANDLOCK_ACCESS_FS_IOCTL_DEV;
  };

  if (what.net) {
    // un-restrict net access
    log::println("landlock: permit net");
    ruleset_attr.handled_access_net = 0;
  }; // XXX: `what.net` only affects TCP. UDP, and ICMP remain possible always

  let ruleset_fd = rtext::landlock_create_ruleset(&ruleset_attr)!;

  for (let path .. what.paths) {
    log::printfln("landlock: permit path: {}", path);
    match (rt::open(path, rt::O_PATH | rt::O_CLOEXEC, 0)) {  //< O_PATH allows for opening files which are `x` but not `r`
      case rt::errno => log::printfln("omitting from sandbox (failed to `open`): {}", path);
      case let path_fd: int => allow_path_fd(ruleset_fd, path_fd)!;
    };
  };

  rtext::landlock_restrict_self(ruleset_fd)!;

  log::println("landlock restrictions activated");
};
