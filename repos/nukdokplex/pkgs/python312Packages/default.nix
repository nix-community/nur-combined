{ python312Packages }: {
  gputil-mathoudebine = python312Packages.callPackage ./gputil-mathoudebine.nix { };
  pyamdgpuinfo = python312Packages.callPackage ./pyamdgpuinfo.nix { };
}
