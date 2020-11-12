path:
let
    lsName = import ./lsName.nix;
in map import (lsName path)