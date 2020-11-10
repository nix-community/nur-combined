{ callPackage } :

{
  cp2k = callPackage ./cp2k/benchmark.nix { };
  dgemm = callPackage ./dgemm/benchmark.nix { };
  bagel = callPackage ./bagel/benchmark.nix { };
  hpcg = callPackage ./hpcg/benchmark.nix { };
  hpl = callPackage ./hpl/benchmark.nix { };
  molcas = callPackage ./molcas/benchmark.nix { };
  molpro = callPackage ./molpro/benchmark.nix { };
  nwchem = callPackage ./nwchem/benchmark.nix { };
  qdng = callPackage ./qdng/benchmark.nix { };
  stream = callPackage ./stream/benchmark.nix { };
}

