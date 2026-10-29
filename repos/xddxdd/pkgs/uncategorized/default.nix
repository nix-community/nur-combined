{
  callPackage,
  ifNotCI,
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
  vivado = ifNotCI (callPackage ./vivado { });
  mtranservercore-rs = callPackage ./linguaspark-server { };
  linguaspark-server-x86-64-v3 = callPackage ./linguaspark-server { buildArch = "x86-64-v3"; };
  ik-llama-cpp-cuda = ifNotCI (callPackage ./ik-llama-cpp { cudaSupport = true; });
  ik-llama-cpp-avx = ifNotCI (callPackage ./ik-llama-cpp { avxSupport = true; });
  ik-llama-cpp-avx2 = ifNotCI (callPackage ./ik-llama-cpp { avx2Support = true; });
  prismml-llama-cpp-cuda = ifNotCI (callPackage ./prismml-llama-cpp { cudaSupport = true; });
  beellama-cpp-cuda = ifNotCI (callPackage ./beellama-cpp { cudaSupport = true; });
}
