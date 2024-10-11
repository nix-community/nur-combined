{
  callPackage,
  ifNotCI,
  loadPackages,
  ...
}:
let
  packages = loadPackages ./. {
    deepspeech-gpu = ifNotCI;
  };
in
packages
// {
  deepspeech-wrappers = ifNotCI (callPackage ./deepspeech-gpu/wrappers.nix { });
  liboqs-unstable = callPackage ./liboqs/unstable.nix { };
  nvlax-530 = callPackage ./nvlax/nvidia-530.nix { };
  svp-mpv = callPackage ./svp/mpv.nix { };
  uesave-0_3_0 = callPackage ./uesave/0_3_0.nix { };
  wechat-uos-without-sandbox = callPackage ./wechat-uos {
    enableSandbox = false;
  };
  # Deprecated alias
  wechat-uos-bin = packages.wechat-uos;
}
