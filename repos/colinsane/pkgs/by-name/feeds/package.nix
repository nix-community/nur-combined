{
  lib,
  newScope,
  sane-data,
  static-nix-shell,
}:

lib.recurseIntoAttrs (lib.makeScope newScope (self: with self; {
  updateWithSuper = false;  #< don't update feeds unless explicitly asked to by the user

  mkFeed = callPackage ./template.nix {};

  feed-pkgs = let
    byName = lib.mapAttrs
      (name: feed-details: mkFeed {
        feedName = name;
        jsonPath = "modules/data/feeds/sources/${name}/default.json";
        inherit (feed-details) url;
      })
      sane-data.feeds
    ;
  in lib.recurseIntoAttrs byName;

  update-feed = static-nix-shell.mkPython3 {
    pname = "update";
    srcRoot = ./.;
    pkgs = [ "feedsearch-crawler" ];
    srcPath = "update.py";
  };
}))
