// vim: set shiftwidth=2 :
use path;

export type resources = struct {
  // paths to allow unrestricted access to (i.e. with whatever permissions the
  // user has naturally.
  paths: []path::buffer,
  // true to allow unrestricted net access.
  // false to maximally disable net access.
  net: bool,
};
