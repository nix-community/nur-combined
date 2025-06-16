{ lib, ... }:

{
  flake = {
    lib = import ../lib { inherit lib; };
  };
}
