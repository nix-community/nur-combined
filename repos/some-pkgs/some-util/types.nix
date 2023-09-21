{ lib, pkgs, ... }:

with lib;
with types;
{
  RemoteFile = submodule ({ config, ... }: {
    options.urls = mkOption { type = listOf str; };
    options.hash = mkOption {
      type = nullOr str;
      default = null;
    };
    options.cid = mkOption {
      type = nullOr str;
      default = null;
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
      package = mkDefault (pkgs.some-pkgs.fetchdata config);
    };
  });
}
