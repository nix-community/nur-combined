{ lib, config, ... }: with lib; let
  inherit (config.services) mpd;
  cfg = config.programs.ncmpcpp;
in {
  config.programs.ncmpcpp = {
    settings = {
      ncmpcpp_directory = mkOptionDefault (config.xdg.dataHome + "/ncmpcpp");
    };
  };
}
