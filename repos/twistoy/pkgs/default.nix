# {pkgs, ...}: {
#   gersemi = pkgs.callPackage ./gersemi {};
#   rime-ls = pkgs.callPackage ./rime-ls {};
# }
{
  lib,
  newScope,
}:
lib.makeScope newScope
(
  self: let
    inherit (self) callPackage;
  in {
    gersemi = callPackage ./gersemi {};
    rime-ls = callPackage ./rime-ls {};
  }
)
