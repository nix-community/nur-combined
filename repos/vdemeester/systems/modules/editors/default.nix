{ config, lib, ... }:
let
  inherit (lib) mkIf mkOption mkOverride types;
  cfg = config.modules.editors;
in
{
  imports = [ ./vim.nix ./emacs.nix ];
  options.modules.editors = {
    default = mkOption {
      description = "default editor";
      type = types.str;
      default = "vim";
    };
  };
  config = mkIf (cfg.default != null) {
    environment.variables = {
      EDITOR = mkOverride 0 cfg.default;
    };
  };
}
