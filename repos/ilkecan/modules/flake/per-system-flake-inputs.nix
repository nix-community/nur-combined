{
  lib,
  ...
}:

{
  perInput = _system: lib.mapAttrs (_: lib.mkDefault);
}
