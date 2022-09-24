{ lib, name, nixosConfig, config, ... }: with lib; let
  arc'lib = import ../../lib { inherit lib; };
  unmerged = lib.unmerged or arc'lib.unmerged;
  cfg = config.nixos;
in {
  options.nixos = {
    enable = mkEnableOption "OS config" // {
      default = (builtins.tryEval (nixosConfig ? users.users)).value;
    };
    hasSettings = mkOption {
      type = types.bool;
      default = cfg.enable && nixosConfig.home.os.enable or false;
    };
    user = mkOption {
      type = types.nullOr types.unspecified;
      default = if cfg.enable
        then nixosConfig.users.users.${name}
        else null;
    };
    settings = mkOption {
      type = unmerged.types.attrs;
      default = { };
    };
  };
}
