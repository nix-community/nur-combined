{ lib, config, ... }: with lib; let
  inherit (config.services) mpd;
  cfg = config.programs.ncmpcpp;
in {
  options.programs.ncmpcpp = {
    mpdHost = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    mpdPassword = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    mpdPort = mkOption {
      type = types.nullOr types.port;
      default = null;
    };
  };

  config.programs.ncmpcpp = {
    mpdPort = mkIf mpd.enable (mkDefault mpd.network.port);
    mpdHost = let
      host = if mpd.network.listenAddress == "any"
        then "localhost" # or: /run/user/${numeric_user_id}/mpd/socket
        else mpd.network.listenAddress;
    in mkIf mpd.enable (mkDefault host);
    settings = {
      ncmpcpp_directory = mkOptionDefault (config.xdg.dataHome + "/ncmpcpp");
      mpd_host = mkIf (cfg.mpdHost != null) (mkOptionDefault (
        optionalString (cfg.mpdPassword != null) (cfg.mpdPassword + "@")
        + cfg.mpdHost
        + optionalString (cfg.mpdPort != null && ! hasPrefix "/" cfg.mpdHost) (":" + toString cfg.mpdPort)
      ));
    };
  };
}
