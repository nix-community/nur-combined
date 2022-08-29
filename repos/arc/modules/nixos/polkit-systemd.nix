{ config, lib, ... }: with lib; let
  cfg = config.security.polkit;
  jsString = s: ''"${s}"'';
  jsValue = jsString;
  jsArray = ls: "[" + concatMapStringsSep ", " jsValue ls + "]";
  userModule = { config, name, ... }: {
    options = {
      user = mkOption {
        type = types.str;
        default = name;
      };
      systemd = {
        enable = mkEnableOption "systemd unit permissions" // {
          default = config.systemd.units != [ ];
        };
        units = mkOption {
          type = with types; listOf str;
          default = [ ];
        };
        verbs = mkOption {
          type = with types; listOf str;
          default = [ "start" "stop" "restart" ];
        };
      };
    };
  };
in {
  options.security.polkit = {
    users = mkOption {
      type = with types; attrsOf (submodule userModule);
      default = { };
    };
  };
  config.security.polkit = {
    extraConfig = mkMerge (mapAttrsToList (_: user: mkIf user.systemd.enable ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" && subject.user == ${jsValue user.user}) {
          if (${jsArray user.systemd.units}.indexOf(action.lookup("unit")) > -1 && ${jsArray user.systemd.verbs}.indexOf(action.lookup("verb")) > -1) {
            return polkit.Result.YES;
          }
        }
      })
    '') cfg.users);
  };
}
