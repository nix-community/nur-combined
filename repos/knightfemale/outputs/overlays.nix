{
  flake.overlays = {
    default = import ./_overlays/default.nix;
    deviceTrees = import ./_overlays/deviceTrees.nix;
    lib = import ./_overlays/lib.nix;
    packages = import ./_overlays/packages.nix;
    python314Packages = import ./_overlays/python314Packages.nix;
  };
}
