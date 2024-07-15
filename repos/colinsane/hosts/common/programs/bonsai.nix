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
        };
      };
    };

    packageUnwrapped = pkgs.bonsai.overrideAttrs (upstream: {
      # patch to place the socket in a subdirectory where it can be sandboxed
      postPatch = (upstream.postPatch or "") + ''
        substituteInPlace cmd/{bonsaictl,bonsaid}/main.ha \
          --replace-fail 'path::set(&buf, statedir, "bonsai")' 'path::set(&buf, statedir, "bonsai/bonsai")'
      '';
    });

    fs.".config/bonsai/bonsai_tree.json".symlink.target = pkgs.writers.writeJSON "bonsai_tree.json" cfg.config.transitions;

    sandbox.method = "bwrap";
    sandbox.extraRuntimePaths = [
      "bonsai"
    ];

    services.bonsaid = {
      description = "bonsai: programmable input dispatcher";
      dependencyOf = [ "sway" ];  # to ensure `$XDG_RUNTIME_DIR/bonsai` exists before sway binds it
      partOf = [ "graphical-session" ];
      # nice -n -11 chosen arbitrarily. i hope this will allow for faster response to inputs, but without audio underruns (pipewire is -21, dino -15-ish)
      command = pkgs.writeShellScript "bonsai-start" ''
        # TODO: don't create the sway directory here!
        # i do it for now because sway and bonsai call into eachother; circular dependency:
        # - sway -> bonsai -> sane-input-handler -> swaymsg
        mkdir -p $XDG_RUNTIME_DIR/{bonsai,sway}
        exec nice -n -11 bonsaid -t $HOME/.config/bonsai/bonsai_tree.json
      '';
      cleanupCommand = "rm -f $XDG_RUNTIME_DIR/bonsai/bonsai";
      readiness.waitExists = [
        "$XDG_RUNTIME_DIR/bonsai/bonsai"
      ];
    };
  };
}
