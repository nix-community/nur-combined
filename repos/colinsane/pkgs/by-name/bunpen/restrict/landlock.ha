// vim: set shiftwidth=2 :
use errors::ext;
use fs;
use log;
use os;
use path;
use resources;
use rt;
use rt::ext;

fn access_fs_roughly_read() rt::ext::landlock_access_fs_set = return
  rt::ext::landlock_access_fs::EXECUTE |
  rt::ext::landlock_access_fs::READ_FILE |
  rt::ext::landlock_access_fs::READ_DIR
;
fn access_fs_roughly_write() rt::ext::landlock_access_fs_set = return
  rt::ext::landlock_access_fs::WRITE_FILE |
  rt::ext::landlock_access_fs::REMOVE_DIR |
  rt::ext::landlock_access_fs::REMOVE_FILE |
  rt::ext::landlock_access_fs::MAKE_CHAR |
  rt::ext::landlock_access_fs::MAKE_DIR |
  rt::ext::landlock_access_fs::MAKE_REG |
  rt::ext::landlock_access_fs::MAKE_SOCK |
  rt::ext::landlock_access_fs::MAKE_FIFO |
  rt::ext::landlock_access_fs::MAKE_BLOCK |
  rt::ext::landlock_access_fs::MAKE_SYM |
  rt::ext::landlock_access_fs::REFER |
  rt::ext::landlock_access_fs::TRUNCATE |
  rt::ext::landlock_access_fs::IOCTL_DEV
;
fn access_fs_roughly_rw() rt::ext::landlock_access_fs_set = return access_fs_roughly_read() | access_fs_roughly_write();
fn access_file() rt::ext::landlock_access_fs_set = return
  rt::ext::landlock_access_fs::EXECUTE |
  rt::ext::landlock_access_fs::WRITE_FILE |
  rt::ext::landlock_access_fs::READ_FILE |
  rt::ext::landlock_access_fs::TRUNCATE |
  rt::ext::landlock_access_fs::IOCTL_DEV
;

fn allow_path_fd(ruleset_fd: u64, path_fd: i32) (void | fs::error | rt::errno) = {
  let access = access_fs_roughly_rw();
  let statbuf = os::fstat(path_fd)?;

  if (!fs::isdir(statbuf.mode)) {
    // not a directory: remove all access modes which are only sensible for
    // directories, else landlock will fail.
    access = access & access_file();
  };

  rt::ext::landlock_add_rule(ruleset_fd, &rt::ext::landlock_path_beneath_attr {
    allowed_access = access,
    parent_fd = path_fd,
  })?;
};

fn allow_path(ruleset_fd: u64, path_str: str) (void | fs::error | rt::errno) = {
  let path_fd = rt::open(path_str, rt::O_PATH | rt::O_CLOEXEC, 0)?;  //< O_PATH allows for opening files which are `x` but not `r`
  allow_path_fd(ruleset_fd, path_fd)?;
};

export fn landlock_restrict(what: *resources::resources) void = {
  let abi = errors::ext::check_u64(
    "query landlock kernel ABI version",
    rt::ext::landlock_create_ruleset(null, rt::ext::landlock_create_ruleset_flag::VERSION),
  );
  log::printfln("[landlock] found version {}", abi);

  // determine the access modes we can ask this kernel to restrict on:
  let ruleset_attr = rt::ext::landlock_ruleset_attr {
    handled_access_fs = access_fs_roughly_rw(),
    handled_access_net = rt::ext::landlock_access_net::BIND_TCP | rt::ext::landlock_access_net::CONNECT_TCP,
  };
  if (abi == 1) {
    ruleset_attr.handled_access_fs &= ~rt::ext::landlock_access_fs::REFER;
  };
  if (abi <= 2) {
    ruleset_attr.handled_access_fs &= ~rt::ext::landlock_access_fs::TRUNCATE;
  };
  if (abi <= 3) {
    ruleset_attr.handled_access_net &= ~(rt::ext::landlock_access_net::BIND_TCP | rt::ext::landlock_access_net::CONNECT_TCP);
  };
  if (abi <= 4) {
    ruleset_attr.handled_access_fs &= ~rt::ext::landlock_access_fs::IOCTL_DEV;
  };

  // XXX: `what.net` only affects TCP. UDP, and ICMP remain possible always
  match (what.net) {
    case resources::net_none => void;
    case let subset: resources::net_subset =>
      log::println("[landlock] unable to retain just a subset of net resources");
    case resources::net_all =>
      log::println("[landlock] permit net");
      ruleset_attr.handled_access_net = 0;
  };

  let ruleset_fd = errors::ext::check_u64(
    "landlock_create_ruleset",
    rt::ext::landlock_create_ruleset(&ruleset_attr),
  );

  for (let pathbuf .. what.paths) {
    let pathstr = path::string(&pathbuf);
    log::printfln("[landlock] permit path: {}", pathstr);
    errors::ext::swallow("[landlock/path] omitting from sandbox: failed to add path", allow_path(ruleset_fd, pathstr));
  };

  errors::ext::check("landlock_restrict_self", rt::ext::landlock_restrict_self(ruleset_fd));

  log::println("landlock restrictions activated");
};
