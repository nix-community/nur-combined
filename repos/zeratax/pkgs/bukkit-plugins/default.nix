{ config, lib, pkgs }:

lib.makeScope pkgs.newScope (self: with self; {
  harbor = self.callPackage ./harbor { };
  dynmap = self.callPackage ./dynmap { };
})
 