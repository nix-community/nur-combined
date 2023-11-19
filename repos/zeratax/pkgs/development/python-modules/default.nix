{ lib, pkgs, python3 }:

# can't use python3packages.newScope since it doesn't implement it
# which means we have to be manually point out the deps :/
lib.makeScope pkgs.newScope (self:
  with self; {
    # example = python3.pkgs.callPackage ./plyer { };
  })
