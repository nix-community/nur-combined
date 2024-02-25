{ lib
, newScope
, python3
, sane-data
, static-nix-shell
, writeShellScript
}:

lib.makeScope newScope (self: with self; {
  mkFeed = callPackage ./template.nix {};
  feed-pkgs = lib.recurseIntoAttrs (lib.mapAttrs
    (name: feed-details: mkFeed {
      feedName = name;
      jsonPath = "modules/data/feeds/sources/${name}/default.json";
      inherit (feed-details) url;
    })
    sane-data.feeds
  );
  update-feed = static-nix-shell.mkPython3Bin {
    pname = "update";
    srcRoot = ./.;
    pyPkgs = [ "feedsearch-crawler" ];
    srcPath = "update.py";
  };
  init-feed = writeShellScript
    "init-feed"
    ''
      # this is the `nix run '.#init-feed' <url>` script`
      sources_dir=modules/data/feeds/sources
      # prettify the URL, by default
      name=$( \
        echo "$1" \
        | sed 's|^https://||' \
        | sed 's|^http://||' \
        | sed 's|^www\.||' \
        | sed 's|/+$||' \
      )
      json_path="$sources_dir/$name/default.json"

      # the name could have slashes in it, so we want to mkdir -p that
      # but in a way where the least could go wrong.
      pushd "$sources_dir"; mkdir -p "$name"; popd

      ${update-feed}/bin/update.py "$name" "$json_path"
      cat "$json_path"
    '';
})
