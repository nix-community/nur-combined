# TODO: Actually use this module
{ lib, ... }: {
  flake.lib = import ./. { inherit lib; };
}
