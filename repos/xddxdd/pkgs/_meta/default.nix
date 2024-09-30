{
  loadPackages,
  ...
}:
let
  meta = import ../../helpers/meta.nix;
in
meta // (loadPackages ./. { })
