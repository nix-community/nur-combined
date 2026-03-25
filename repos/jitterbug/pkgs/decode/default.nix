{
  pkgs,
  ...
}:
let
  inherit (pkgs.callPackage ../lib { inherit pkgs; }) callPackage;
in
{
  ld-decode = callPackage ./ld-decode { };
  ld-decode-unstable = callPackage ./ld-decode/unstable.nix { };
  vhs-decode = callPackage ./vhs-decode { };
  vhs-decode-unstable = callPackage ./vhs-decode/unstable.nix { };
}
