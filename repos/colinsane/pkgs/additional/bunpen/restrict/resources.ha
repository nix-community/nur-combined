// vim: set shiftwidth=2 :
use path;
use rt::ext;

export type resources = struct {
  // paths to allow unrestricted access to (i.e. with whatever permissions the
  // user has naturally.
  paths: []path::buffer,
  all_caps: bool,
  caps: rt::ext::caps,
  // true to allow unrestricted net access.
  // false to maximally disable net access.
  net: bool,
  // true to allow operations on other processes (e.g. viewing their cmdline,
  // killing them, etc).
  pid: bool,
};
