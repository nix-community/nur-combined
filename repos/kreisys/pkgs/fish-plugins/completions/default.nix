{ stdenv, newScope }:

stdenv.lib.makeScope newScope (self: with self; {
  docker         = callPackage ./docker.nix         {};
  docker-compose = callPackage ./docker-compose.nix {};
})
