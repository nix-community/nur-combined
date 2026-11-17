{folder}: let
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;
  helper = import ../../lib/helper.nix {inherit pkgs lib;};

  ver = helper.read (folder + "/version.json");
  source = ver.source.type or "";
  expand = ver.asset.unpack or false;

  platforms =
    if ver ? platforms
    then
      map (
        platform: let
          asset = helper.getPlatform platform ver;
          settings = ver.platforms.${platform};
        in {
          kind = "platform";
          id = platform;
          inherit (asset) url name;
          unpack = settings.unpack or expand;
        }
      ) (builtins.attrNames ver.platforms)
    else [];

  variants =
    if ver ? variants
    then
      map (
        variant: let
          asset = helper.getVariant variant ver;
        in {
          kind = "variant";
          id = variant;
          inherit (asset) url name;
          unpack = expand;
        }
      ) (builtins.attrNames ver.variants)
    else [];

  single =
    if (ver ? platforms) || (ver ? variants)
    then []
    else if source == "github-repo"
    then let
      repo = helper.getSingle ver;
    in [
      {
        kind = "source";
        id = "repo";
        url = "https://github.com/${repo.owner}/archive/${repo.tag}.tar.gz";
        name = "${repo.repo}-${repo.tag}.tar.gz";
        unpack = false;
      }
    ]
    else let
      asset = helper.getSingle ver;
    in [
      {
        kind = "asset";
        id = "asset";
        inherit (asset) url name;
        unpack = expand;
      }
    ];
in
  platforms ++ variants ++ single
