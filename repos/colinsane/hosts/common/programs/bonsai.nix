# bonsai docs: <https://sr.ht/~stacyharper/bonsai/>
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.bonsai;

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
in
{
  sane.programs.bonsai = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options = {
          transitions = mkOption {
            type = types.listOf transitionType;
            default = [];
          };
          configFile = mkOption {
            type = types.path;
            default = pkgs.writeText "bonsai_tree.json" (builtins.toJSON cfg.config.transitions);
            description = ''
              configuration file to pass to bonsai.
              usually auto-generated from the sibling options; exposed mainly for debugging or convenience.
            '';
          };
        };
      };
    };

    sandbox.method = "bwrap";
    sandbox.extraRuntimePaths = [
      "/"  #< just needs "bonsai", but needs to create it first...
    ];

    services.bonsaid = {
      description = "bonsai: programmable input dispatcher";
      partOf = [ "graphical-session" ];
      # nice -n -11 chosen arbitrarily. i hope this will allow for faster response to inputs, but without audio underruns (pipewire is -21, dino -15-ish)
      command = "nice -n -11 bonsaid -t ${cfg.config.configFile}";
      cleanupCommand = "rm -f $XDG_RUNTIME_DIR/bonsai";
    };
  };
}
