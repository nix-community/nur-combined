{ config, lib, options, ... }:
with lib;
let
  cfg = config.home-dir;
in {
  options.home-dir = {
    home_dir = mkOption {
      type = types.str;
      default = "/home/scott";
      description = "Home dir";
    };
  };
  config = {};
}
