{
  callPackage,
  loadPackages,
  ...
}:
let
  packages = loadPackages ./. { };
in
packages
// {
  liboqs-unstable = callPackage ./liboqs/unstable.nix { };
  nvlax-530 = callPackage ./nvlax/nvidia-530.nix { };
  svp-mpv = callPackage ./svp/mpv.nix { };
  uesave-0_3_0 = callPackage ./uesave/0_3_0.nix { };
}
