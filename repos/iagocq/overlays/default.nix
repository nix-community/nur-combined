with builtins;
let
  all = {
    nur = final: prev: import ../pkgs { pkgs = prev; };
    zig-nightly = import ./zig-nightly.nix;
  };
in
all // {
  merged = final: prev: foldl' (x: y: x // (y final prev)) { } (attrValues all);
}
