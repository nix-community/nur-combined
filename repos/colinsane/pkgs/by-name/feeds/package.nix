{
  feedsearch-crawler,
  lib,
  newScope,
  podcastindex-db,
  sane-feeds,
  static-nix-shell,
}:

lib.recurseIntoAttrs (lib.makeScope newScope (self: with self; {
  skipBulkUpdate = true;  #< don't update feeds unless explicitly asked to by the user

  mkFeed = callPackage ./template.nix {};

  feed-pkgs = let
    byName = lib.mapAttrs
      (name: feed-details: mkFeed {
        feedName = name;
        jsonPath = "pkgs/by-name/sane-feeds/sources/${name}/default.json";
        inherit (feed-details) url;
      })
      (lib.filterAttrs (_: lib.isDerivation) sane-feeds)
    ;
  in lib.recurseIntoAttrs byName;

  update-feed = static-nix-shell.mkPython3 {
    pname = "update-feed";
    srcRoot = ./.;
    pkgs = {
      inherit
        feedsearch-crawler
        podcastindex-db
        ;
    };
  };
}))
