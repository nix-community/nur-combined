# bonsai docs: <https://sr.ht/~stacyharper/bonsai/>
{ config, lib, options, pkgs, ... }:
let
  cfg = config.sane.programs.bonsai;
in
{
  sane.programs.bonsai = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options = {
          transitions = mkOption {
            type = options.services.bonsaid.settings.type;
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

    fs.".config/bonsai/bonsai_tree.json".symlink.target = config.services.bonsaid.configFile;

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
        mkdir -p ''${XDG_RUNTIME_DIR}/{bonsai,sway}
        exec nice -n -11 bonsaid -t ''${HOME}/.config/bonsai/bonsai_tree.json
      '';
      cleanupCommand = ''rm -f ''${XDG_RUNTIME_DIR}/bonsai/bonsai'';
      readiness.waitExists = [
        ''''${XDG_RUNTIME_DIR}/bonsai/bonsai''
      ];
    };
  };

  # plug into the (proposed) nixpkgs bonsaid service.
  # it's a user service, and since i don't use the service manager it doesn't actually activate:
  # i just steal the config file generation from it :)
  services.bonsaid.settings = lib.mkIf cfg.enabled (lib.mkMerge [
    cfg.config.transitions
    [{
      type = "delay";
      transitions = [];
      # speculative: i've observed a hang inside bonsai (rather, hare-ev) where it
      # attempts to read from a timer, assuming it to have expired, and the read *never* returns.
      # i think this can happen when an `exec` and a `delay` trigger simultaneously?
      # particularly, hare-ev does the exec action callback, during which bonsaid enters a node w/o delay and *disables* the timer, and then reading the timer hangs.
      # if true, then adding a delay to the root node alleviates that (so long as all other nodes also have delays).
      #
      # long term, it may be best to move away from bonsai. aside from the above, it's really easy to get it to segfault.
      delay_duration = 30000 * 1000000;
    }]
  ]);
  # vvv not actually necessary. TODO: delete this line once the service is upstreamed?
  services.bonsaid.enable = lib.mkIf cfg.enabled true;
}
