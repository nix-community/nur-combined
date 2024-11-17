# .zim files are web dumps (html + images, etc) designed for read-only mirroring.
# so they package search indexes and such too.
# use together with kiwix.
#
# zim downloads:
# - https://mirror.accum.se/mirror/wikimedia.org/other/kiwix/zim
# - https://dumps.wikimedia.org/other/kiwix/zim
# - https://download.kiwix.org/zim
{
  lib,
  newScope,
}:
lib.recurseIntoAttrs (lib.makeScope newScope (self: with self; {
  mkVersionedHttpZim = callPackage ./mkVersionedHttpZim.nix { };

  wikipedia_en_100 = callPackage ./wikipedia_en_100.nix { };
  wikipedia_en_all_maxi = callPackage ./wikipedia_en_all_maxi.nix { };
  wikipedia_en_all_mini = callPackage ./wikipedia_en_all_mini.nix { };
}))
