{ lib }:

with lib.types;
{
  # I'll be just manually passing the stupid { inherit pkgs; } for now...
  remoteFile = { pkgs }: lib.types.submodule ({ config, ... }: {
    options.urls = lib.mkOption { type = types.listOf types.str; };
    options.hash = lib.mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    options.cid = lib.mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    options.package = lib.mkOption {
      type = types.package;
      default = pkgs.some-pkgs.fetchdata config;
    };
    config = {
      urls = lib.mkIf (config.cid != null) (lib.mkAfter [
        "https://ipfs.io/ipfs/${config.cid}"
        "https://cloudflare-ipfs.com/ipfs/${config.cid}"
      ]);
    };
  });
}
