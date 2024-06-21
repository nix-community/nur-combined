{ lib, newScope, ... }:
lib.makeScope newScope (self: with self; {
  mpi = callPackage ./mpi { };
})
