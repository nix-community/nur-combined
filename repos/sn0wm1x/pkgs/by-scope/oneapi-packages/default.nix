{ lib, newScope, ... }:
lib.makeScope newScope (self: with self; {
  basekit = callPackage ./basekit { };
  mpi = callPackage ./mpi { };
})
