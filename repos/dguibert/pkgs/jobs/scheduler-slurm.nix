# see jobs/default.nix
{
  final,
  prev,
  date ? "20181211",
}:
with final;
with jobs.scheduler_slurm; {
  # https://gist.github.com/giovtorres/8c0d97b4049534ab82b5
  scontrol_show = keyword: condition: let
    json_file = "${keyword}.json";
    scontrol_show_py = writeScript "scontrol-show.py" ''
      #!${python}/bin/python
      import sys
      from datetime import datetime
      from operator import itemgetter

      import time
      import argparse
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

      parser = argparse.ArgumentParser()
      parser.add_argument("${keyword}", nargs="*", help="show ${keyword}")
      args = parser.parse_args()

      try:
        ${keyword} = pyslurm.${keyword}()
        all_ = ${keyword}.get()
      except ValueError as e:
        print("${keyword} error - {0}".format(e.args[0]))
        exit(1)
      else:
        if args.${keyword}:
            all_ = { "%s" % args.${keyword}[0]: all_.get(args.${keyword}[0]) }
        if len(all_) > 0:
          print(json.dumps(all_, sort_keys=True))
          #display(all_)
    '';
  in
    runCommand "${json_file}" {
      buildInputs = with final; [coreutils jq pythonPackages.pyslurm];
      hashChangingValue = builtins.currentTime;
    } ''
      set -xeufo pipefail
      ${scontrol_show_py} | jq '.[] | .name'
      ${scontrol_show_py} | jq '.' |sed -e 's@\\u001b\[D@ @g' > $out
      set +x
    '';

  partitions_json = final.jobs.scheduler_slurm.scontrol_show "partition" "";
  nodes_json = final.jobs.scheduler_slurm.scontrol_show "node" ""; #"=genji500";

  partitions = let
    extendNodeSet = p
    /*
    name
    */
    : p_
    /*
    value
    */
    :
      p_
      // rec {
        name = p;
        nodeset_ = lib.splitString " " (builtins.readFile (runCommand "nodeset-${p}" {} ''
          set -xeufo pipefail
          nodeset=$(${pythonPackages.clustershell}/bin/nodeset -e -S' ' -O '%s' ${p_.nodes})
          echo -n $nodeset > $out
          set +x
        ''));
        # keep only available nodes
        nodeset = filtered_nodes nodeset_;
      };
  in
    lib.mapAttrs extendNodeSet (builtins.fromJSON (builtins.readFile final.jobs.scheduler_slurm.partitions_json));

  nodes = builtins.fromJSON (builtins.readFile final.jobs.scheduler_slurm.nodes_json);

  filtered_nodes = node_names:
    builtins.filter (
      n: let
        n_ = builtins.getAttr n nodes;
      in
        n_.state
        != "DOWN"
        && n_.state != "DOWN*"
        && n_.state != "DOWN*+DRAIN"
        && n_.state != "IDLE+DRAIN"
        && n_.state != "RESERVED"
        && n_.state != "RESERVED+DRAIN"
    )
    node_names;
}
