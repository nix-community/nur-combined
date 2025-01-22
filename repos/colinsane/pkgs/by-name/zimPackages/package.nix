# .zim files are web dumps (html + images, etc) designed for read-only mirroring.
# so they package search indexes and such too.
# use together with kiwix.
#
# zim downloads:
# - https://mirror.accum.se/mirror/wikimedia.org/other/kiwix/zim
# - https://dumps.wikimedia.org/other/kiwix/zim
# - https://download.kiwix.org/zim
# - https://mirror.download.kiwix.org/zim/.hidden/
{
  lib,
  newScope,
}:
lib.recurseIntoAttrs (lib.makeScope newScope (self: with self; {
  mkVersionedHttpZim = callPackage ./mkVersionedHttpZim.nix { };

  alpinelinux_en_all_maxi = callPackage ./alpinelinux_en_all_maxi.nix { };
  archlinux_en_all_maxi = callPackage ./archlinux_en_all_maxi.nix { };
  bitcoin_en_all_maxi = callPackage ./bitcoin_en_all_maxi.nix { };
  devdocs_en_nix = callPackage ./devdocs_en_nix.nix { };
  gentoo_en_all_maxi = callPackage ./gentoo_en_all_maxi.nix { };
  khanacademy_en_all = callPackage ./khanacademy_en_all.nix { };
  openstreetmap-wiki_en_all_maxi = callPackage ./openstreetmap-wiki_en_all_maxi.nix { };
  psychonautwiki_en_all_maxi = callPackage ./psychonautwiki_en_all_maxi.nix { };
  rationalwiki_en_all_maxi = callPackage ./rationalwiki_en_all_maxi.nix { };
  wikipedia_en_100 = callPackage ./wikipedia_en_100.nix { };
  wikipedia_en_all_maxi = callPackage ./wikipedia_en_all_maxi.nix { };
  wikipedia_en_all_mini = callPackage ./wikipedia_en_all_mini.nix { };
  zimgit-food-preparation_en = callPackage ./zimgit-food-preparation_en.nix { };
  zimgit-medicine_en = callPackage ./zimgit-medicine_en.nix { };
  zimgit-post-disaster_en = callPackage ./zimgit-post-disaster_en.nix { };
  zimgit-water_en = callPackage ./zimgit-water_en.nix { };
}))
