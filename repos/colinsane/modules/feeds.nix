{ lib, sane-data, ... }:

with lib;
let
  feed = types.submodule ({ config, ... }: {
    options = {
      freq = mkOption {
        type = types.enum [ "hourly" "daily" "weekly" "infrequent" ];
        default = "infrequent";
      };
      cat = mkOption {
        type = types.enum [ "art" "humor" "pol" "rat" "tech" "uncat" ];
        default = "uncat";
      };
      format = mkOption {
        type = types.enum [ "text" "image" "podcast" ];
        default = "text";
      };
      title = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      url = mkOption {
        type = types.str;
        description = ''
          url to a RSS feed
        '';
      };
      substack = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          if the feed is a substack domain, just enter the subdomain here and the url/format field can be populated automatically
        '';
      };
    };
    config = lib.mkIf (config.substack != null) {
      url = "https://${config.substack}.substack.com/feed";
      format = "text";
    };
  });
in
{
  # we don't explicitly generate anything from the feeds here.
  # instead, config.sane.feeds is used by a variety of services at their definition site.
  options = {
    sane.feeds = mkOption {
      type = types.listOf feed;
      default = [];
      description = ''
        RSS feeds indexed by a human-readable name.
      '';
    };
  };
}
