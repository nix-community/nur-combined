{ lib
, newScope
, python3
, sane-data
, static-nix-shell
, symlinkJoin
, writeShellScript
}:

lib.makeScope newScope (self: with self; {
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
  in
    symlinkJoin {
      # this meta package exists primarily to link all the feed updaters
      # into a single package which can *actually* be updated.
      # it's not critical whether the actual package itself builds.
      name = "feed-pkgs";
      pname = "feed-pkgs";
      version = "20230112";
      paths = builtins.attrValues byName;
      passthru = byName // {
        updateScript = let
          update-all-feeds = writeShellScript "update-all-feeds" (
            lib.concatStringsSep "\n" (
              builtins.map (p: lib.concatStringsSep " " p.updateScript) (lib.attrValues byName)
            )
          );
        in
          [ update-all-feeds ];
      };
    };
  update-feed = static-nix-shell.mkPython3 {
    pname = "update";
    srcRoot = ./.;
    pkgs = [ "feedsearch-crawler" ];
    srcPath = "update.py";
  };
})
