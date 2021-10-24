{ config, lib, pkgs, ... }: with lib;

let cfg = config.programs.swaylock; in
{
  options.programs.swaylock = {
    enable = mkEnableOption "locker integration";
    package = mkOption {
      type = types.package;
      default = pkgs.swaylock-effects;
    };
    wrapped = mkOption {
      type = types.package;
    };
    script = mkOption {
      type = types.path;
      default = "${cfg.wrapped}/bin/swaylock";
    };
    colors = mkOption {
      type = types.attrsOf types.str;
      default = { };
    };
    args = mkOption {
      type = with types; attrsOf (oneOf [ str bool int float ]);
      default = { };
    };
  };
  config = mkIf cfg.enable {
    programs.swaylock =
      let
        argList = concatLists (mapAttrsToList
          (arg: value:
            if value == true then
              singleton "--${toString arg}"
            else if value == false then
              []
            else [
              "--${arg}"
              (toString value)
            ])
          cfg.args);
        argStr = escapeShellArgs argList;
      in
      {
        args = mapAttrs' (arg: color: nameValuePair ("${arg}-color") (removePrefix "#" color)) cfg.colors;
        wrapped = pkgs.writeShellScriptBin "swaylock" ''
          ${cfg.package}/bin/swaylock ${argStr} $@
        '';
      };
  };
}
