{ lib, newScope, pythonPackages }:
with lib;
let
  upstreamNewScope = scope: newScope (pythonPackages // scope);
  packages = (self: with self; rec {
  });
in
  makeScope upstreamNewScope packages
