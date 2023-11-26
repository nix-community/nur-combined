# bonsai docs: <https://sr.ht/~stacyharper/bonsai/>
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.gui.sxmo.bonsaid;

  delayType = with lib; types.submodule {
    options = {
      type = mkOption {
        type = types.enum [ "delay" ];
        # default = "delay";
      };
      delay_duration = mkOption {
        type = types.int;
        description = ''
          used for "delay" types only.
          nanoseconds until the event is finalized.
        '';
      };
      transitions = mkOption {
        type = types.listOf transitionType;
        default = [];
        description = ''
          list of transitions out of this state (i.e. after completing the delay).
        '';
      };
    };
  };
  eventType = with lib; types.submodule {
    options = {
      type = mkOption {
        type = types.enum [ "event" ];
        # default = "event";
      };
      event_name = mkOption {
        type = types.str;
        description = ''
          name of event which this transition applies to.
        '';
      };
      transitions = mkOption {
        type = types.listOf transitionType;
        default = [];
        description = ''
          list of transitions out of this state.
        '';
      };
    };
  };
  execType = with lib; types.submodule {
    options = {
      type = mkOption {
        type = types.enum [ "exec" ];
        # default = "exec";
      };
      command = mkOption {
        type = types.listOf types.str;
        description = ''
          command to run when the event is triggered.
        '';
      };
      transitions = mkOption {
        type = types.listOf transitionType;
        default = [];
        description = ''
          list of transitions out of this state (i.e. after successfully executing the command)
        '';
      };
    };
  };
  isDelay = x: delayType.check x && x.type == "delay";
  isEvent = x: eventType.check x && x.type == "event";
  isExec = x: execType.check x && x.type == "exec";
  # unfortunately, `types.oneOf` is naive about submodules, so we need our own type.
  #   transitionType = lib.types.oneOf [ delayType eventType execType ];
  transitionType = with lib.types; mkOptionType {
    name = "transition";
    check = x: isDelay x || isEvent x || isExec x;
    merge = loc: defs: let
      defList = builtins.map (d: d.value) defs;
    in
      if builtins.all isDelay defList then
        delayType.merge loc defs
      else if builtins.all isEvent defList then
        eventType.merge loc defs
      else if builtins.all isExec defList then
        execType.merge loc defs
      else
        mergeOneOption loc defs
    ;
  };

  # transitionType = with lib; types.submodule {
  #   options = {
  #     type = mkOption {
  #       type = types.enum [ "delay" "event" "exec" ];
  #     };
  #     delay_duration = mkOption {
  #       type = types.nullOr types.int;
  #       default = null;
  #       description = ''
  #         used for "delay" types only.
  #         nanoseconds until the event is finalized.
  #       '';
  #     };
  #     event_name = mkOption {
  #       type = types.nullOr types.str;
  #       default = null;
  #       description = ''
  #         name of event which this transition applies to.
  #       '';
  #     };
  #     transitions = mkOption {
  #       type = types.nullOr (types.listOf transitionType);
  #       default = null;
  #       description = ''
  #         list of transitions out of this state.
  #       '';
  #     };
  #     command = mkOption {
  #       type = types.nullOr (types.listOf types.str);
  #       default = null;
  #       description = ''
  #         used for "exec" types only.
  #         command to run when the event is triggered.
  #       '';
  #     };
  #   };
  # };
in
{
  options = with lib; {
    sane.gui.sxmo.bonsaid.package = mkOption {
      type = types.package;
      default = pkgs.bonsai;
    };
    sane.gui.sxmo.bonsaid.transitions = mkOption {
      type = types.listOf transitionType;
      default = [];
    };
    sane.gui.sxmo.bonsaid.configFile = mkOption {
      type = types.path;
      default = pkgs.writeText "bonsai_tree.json" (builtins.toJSON cfg.transitions);
      description = ''
        configuration file to pass to bonsai.
        usually auto-generated from the sibling options; exposed mainly for debugging or convenience.
      '';
    };
  };
  config = lib.mkIf config.sane.gui.sxmo.enable {
    sane.user.services.bonsaid = {
      description = "programmable input dispatcher";
      script = ''
        ${pkgs.coreutils}/bin/rm -f $XDG_RUNTIME_DIR/bonsai
        exec ${cfg.package}/bin/bonsaid -t ${cfg.configFile}
      '';
      serviceConfig.Type = "simple";
      serviceConfig.Restart = "always";
      serviceConfig.RestartSec = "5s";
    };
  };
}
