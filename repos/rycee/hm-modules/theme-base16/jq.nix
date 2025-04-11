{ config, lib, ... }:

let

  inherit (lib) mkDefault mkIf mkOption types;

  colors = config.theme.base16.colors;

in {
  options.programs.jq.enableBase16Theme = mkOption {
    type = types.bool;
    default = true;
    example = false;
    description = "Enable Base16 theme.";
  };

  config = mkIf config.programs.jq.enableBase16Theme {
    programs.jq.colors = {
      null = mkDefault "38;5;9";
      false = mkDefault "38;5;9";
      true = mkDefault "38;5;9";
      numbers = mkDefault "0;37";
      strings = mkDefault "0;32";
      arrays = mkDefault "0;37";
      objects = mkDefault "0;32";
      objectKeys = mkDefault "1;34";
    };
  };
}
