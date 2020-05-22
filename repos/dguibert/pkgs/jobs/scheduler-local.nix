# see jobs/default.nix
{ pkgs
, date ? "20181210"
}:
with pkgs;

let
  define_job_basename_sh = name: ''job_out=$(basename $out); job_basename=${name}-''${job_out:0:12}'';
  scheduler_local = rec {
    job_template = name: options: script: writeScript "${name}.sh" ''
      #!${stdenv.shell}

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
      ${job} 2>&1 | tee $out/job
      echo "job has run"
      set +x
    '';

    partitions.local = {
      nodeset = lib.splitString " " (builtins.readFile (runCommand "nodeset-local" { buildInputs = [ pkgs.nettools ]; } ''
        set -xeufo pipefail
        nodeset=$(hostname)
        echo -n $nodeset > $out
        set +x
      ''));
    };
  };

in scheduler_local
