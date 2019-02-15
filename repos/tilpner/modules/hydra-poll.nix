{ config, pkgs, lib, ... }:

# This module exists for pull-style deployment of Hydra artifacts, after I searched for
# and didn't find any official way to do so in Hydra. If you know of one, please tell me.

# Possible TODOs:
#   postRun

with lib;
let
  cfg = config.services.hydra-poll;
  escape = escapeShellArg;

  mkJobService = job: {
    path = with pkgs; [ curl jq config.nix.package ];

    script = ''
      OUT=$(
        curl \
          --location \
          --header 'Accept: application/json' \
          --retry 5 \
          ${escape
            "${job.endpoint.url}/job/${job.project}/${job.jobset}/${job.job}/latest-finished"} |
            jq -r .buildoutputs.out.path
      )

      echo "Current latest-finished is $OUT"

      PROFILE=${escape "/nix/var/nix/profiles/hydra-poll/${job.endpoint.name}/${job.project}/${job.jobset}/${job.job}"}
      mkdir -p "$(dirname "$PROFILE")"

      if [[ "$OUT" == ${builtins.storeDir}* ]]; then
        nix-env --profile "$PROFILE" --set "$OUT"

        ROOT=${escape job.root}
        if [[ ! -L "$ROOT" ]] || [[ "$(readlink "$ROOT")" != "$OUT" ]]; then
          echo fixing symlink
          ln -s "$PROFILE" "$ROOT.new"
          mv -T "$ROOT.new" "$ROOT"
        fi
      fi
    '';
  };

  mkJobTimer = job: {
    timerConfig = {
      OnCalendar = job.interval;
      Persistent = true;
    };

    wantedBy = [ "timers.target" ];
  };
in {
  options.services.hydra-poll = with types; {
    jobs = with types; mkOption {
      default = {};
      type = attrsOf (submodule ({ ... }: {
        options = {
          endpoint = {
            name = mkOption { type = string; };
            url = mkOption { type = string; };
          };
          project = mkOption { type = string; };
          jobset = mkOption { type = string; };
          job = mkOption { type = string; };
          root = mkOption { type = path; };
          interval = mkOption { type = string; };
        };
      }));
    };
  };

  config = {
    systemd.services =
      mapAttrs'
        (n: v: let job = v // { name = n; }; in
          (nameValuePair "hydra-poll-${n}" (mkJobService job)))
        cfg.jobs;

    systemd.timers =
      mapAttrs'
        (n: v: let job = v // { name = n; }; in
          (nameValuePair "hydra-poll-${n}" (mkJobTimer job)))
        cfg.jobs;
  };
}
