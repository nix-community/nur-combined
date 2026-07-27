{ lib, pkgs, ... }:

with lib;
with types;
{
  RemoteFile = submodule ({ config, name, ... }: {
    options.name = mkOption {
      type = str;
      default = name;
    };
    options.urls = mkOption { type = listOf str; };
    options.hash = mkOption {
      type = str;
      default = lib.fakeHash;
    };
    options.cid = mkOption {
      type = nullOr str;
      default = null;
    };
    options.fetcher = mkOption {
      type = functionTo package;
      default = pkgs.some-pkgs.fetchdata;
    };
    options.package = mkOption {
      type = package;
    };
    config = {
      urls = mkIf (config.cid != null) (mkMerge [
        (mkBefore [
          "https://ipfs.1.someonex.net/ipfs/${config.cid}"
        ])
        (mkAfter [
          "https://ipfs.io/ipfs/${config.cid}"
          "https://cloudflare-ipfs.com/ipfs/${config.cid}"
        ])
      ]);
      package = mkDefault (
        # let
        #   fargs = lib.functionArgs config.fetcher;
        #   args = builtins.intersectAttrs fargs config;
        # in
        config.fetcher config
      );
    };
  });
}
