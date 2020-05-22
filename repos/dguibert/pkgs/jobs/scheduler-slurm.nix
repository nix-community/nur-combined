# see jobs/default.nix
{ pkgs
, date ? "20181210"
}:
with pkgs;

let
  define_job_basename_sh = name: ''job_out=$(basename $out); job_basename=${name}-''${job_out:0:12}'';
  scheduler_sbatch = rec {
    job_template = name: options: script: writeScript "${name}.sbatch" ''
      #!${stdenv.shell}
      ${lib.concatMapStrings (n: if lib.isBool options.${n} then
           lib.optionalString options.${n} "#SBATCH --${n}\n"
      else "#SBATCH --${n}=${options.${n}}\n") (lib.attrNames options)}

      source ${stdenvNoCC}/setup
      set -ue -o pipefail
      runHook jobSetup
      set -x
      ${script}
      set +x
      runHook jobDone
      echo 'done'
    '';

    runJob = { name
             , job ? job_template name options script
             , script ? ""
             , options ? {}
             , buildInputs ? []
             , scratch ? null
             }: let
      in runCommand name {
             buildInputs = [
               /*benchPrintEnvironmentHook*/
             ] ++ buildInputs;
             outputs = [ "out" ] ++ lib.optional (scratch !=null) "scratch";
      } ''
      failureHooks+=(_benchFail)
      _benchFail() {
        cat $out/job
      }
      set -xuef -o pipefail
      mkdir $out
      ${define_job_basename_sh name}
      ${lib.optionalString (scratch !=null) ''
        echo "${scratch}/$job_basename" > $scratch
        scratch_=$(cat $scratch)
        mkdir -p $scratch_; cd $scratch_
      ''}
      cancel() {
        scancel $(squeue -o %i -h -n $job_basename)
      }
      echo 'scancel $(squeue -o %i -h -n '$job_basename')'
      trap "cancel" USR1 INT TERM

      id=$(/usr/bin/sbatch --job-name=$job_basename --parsable --wait -o $out/job ${job})
      /usr/bin/scontrol show JobId=$id
      echo "job $id has run"
      cat $out/job

      set +x
    '';

    # https://gist.github.com/giovtorres/8c0d97b4049534ab82b5
    scontrol_show = keyword: condition: let
        json_file="${date}-${keyword}.json";
        scontrol_show_py = writeScript "scontrol-show.py" ''
          #!${python}/bin/python
          import sys
          from datetime import datetime
          from operator import itemgetter

          import time
          import pyslurm
          import json

          def display(part_dict):
            if len(part_dict) > 0:
              for key, value in part_dict.items():
                print("{0} :".format(key))
                for part_key in sorted(value.keys()):
                  valStr = value[part_key]
                  if 'default_time' in part_key:
                    if isinstance(value[part_key], int):
                      valStr = "{0} minutes".format(value[part_key]/60)
                    else:
                      valStr = value[part_key]
                  elif part_key in [ 'max_nodes', 'max_time', 'max_cpus_per_node']:
                    if value[part_key] == "UNLIMITED":
                      valStr = "Unlimited"
                  print("\t{0:<20} : {1}".format(part_key, valStr))
                print('{0:*^80}'.format(""))


          try:
            ${keyword} = pyslurm.${keyword}()
            all_ = ${keyword}.get()
          except ValueError as e:
            print("${keyword} error - {0}".format(e.args[0]))
            exit(1)
          else:
            if len(all_) > 0:
              print(json.dumps(all_, sort_keys=True))
              #display(all_)
        '';
      in runCommand "${json_file}" { buildInputs = [ coreutils jq pythonPackages.pyslurm ]; } ''
      set -xeufo pipefail
      ${scontrol_show_py} | jq '.' |sed -e 's@\\u001b\[D@ @g' > $out
      set +x
    '';

    partitions_json = scontrol_show "partition" "";
    nodes_json      = scontrol_show "node" ""; #"=genji500";

    partitions = let
      extendNodeSet = p/*name*/: p_/*value*/:
        p_ // rec {
          name = p;
          nodeset_ = lib.splitString " " (builtins.readFile (runCommand "nodeset-${p}" {} ''
            set -xeufo pipefail
            nodeset=$(/usr/bin/nodeset -e -S' ' -O '%s' ${p_.nodes})
            echo -n $nodeset > $out
            set +x
          ''));
          # keep only available nodes
          nodeset = filtered_nodes nodeset_;
        };
      in lib.mapAttrs extendNodeSet (builtins.fromJSON (builtins.readFile partitions_json));

    nodes = builtins.fromJSON (builtins.readFile nodes_json);

    filtered_nodes = node_names: builtins.filter (n:
    let n_ = builtins.getAttr n nodes; in n_.state != "DOWN"
                                       && n_.state != "DOWN*"
                                       && n_.state != "DOWN*+DRAIN"
                                       && n_.state != "IDLE+DRAIN"
                                       && n_.state != "RESERVED"
                                       && n_.state != "RESERVED+DRAIN"
       )
       node_names;
  };

in scheduler_sbatch
