{
  stdenvNoCC,
  lib,
  writeScript,
  runCommand,
  scontrol_show,
}: {
  name,
  script ? "",
  buildInputs ? [],
  scratch ? null,
  ...
} @ args: let
  define_job_basename_sh = name: ''job_out=$(basename $out); job_basename=${name}-''${job_out:0:12}'';

  args_names = builtins.attrNames args;
  options_args = builtins.filter (x: (builtins.match "^sbatch-.*" x) != null) args_names;

  job_name =
    if args ? sbatch-job-name
    then args.sbatch-job-name
    else "$job_basename";

  job = writeScript "${name}.sbatch" ''
    #!${stdenvNoCC.shell}
    ${lib.concatMapStrings (n: let
      n_ = builtins.head (builtins.match "^sbatch-(.*)" n);
    in
      if lib.isBool args.${n}
      then lib.optionalString args.${n} "#SBATCH --${n_}\n"
      else "#SBATCH --${n_}=${args.${n}}\n")
    options_args}

    source ${stdenvNoCC}/setup
    set -ue -o pipefail
    runHook jobSetup
    set -x
    ${script}
    set +x
    runHook jobDone
    echo 'done'
  '';
  extraArgs = removeAttrs args (["name" "buildInputs" "outputs" "script" "scratch"] ++ options_args);
in
  builtins.trace extraArgs
  runCommand
  name (extraArgs
    // {
      inherit buildInputs;
      outputs = ["out"] ++ lib.optional (scratch != null) "scratch";
      impureEnvVars = ["KRB5CCNAME"];
    }) ''
    #failureHooks+=(_benchFail)
    #_benchFail() {
    #  cat $out/job
    #  exit 0
    #}
    set -xuef -o pipefail
    export PATH=$PATH:/usr/bin
    mkdir $out
    ${define_job_basename_sh name}
    ${lib.optionalString (scratch != null) ''
      echo "${scratch}/$job_basename" > $scratch
      scratch_=$(cat $scratch)
      mkdir -p $scratch_; cd $scratch_
    ''}
    # TRAP SIGINT AND SIGTERM OF THIS SCRIPT
    function control_c {
        echo -en "\n SIGINT: TERMINATING SLURM JOBID $JOBID AND EXITING \n"
        scancel $JOBID
        exit $?
    }
    function control_exit {
        echo "job $JOBID has run"
        cat $out/job
        exit $?
    }
    trap control_c SIGINT
    trap control_c SIGTERM
    trap control_exit EXIT

    env | sort

    export JOBID=$(sbatch --job-name=${job_name} --parsable -o $out/job ${job})
    set +x

    NODE=$(squeue -hj $JOBID -O nodelist )
    if [[ -z "''${NODE// }" ]]; then
       echo  " "
       echo -n "    WAITING FOR RESOURCES TO BECOME AVAILABLE (CTRL-C TO EXIT) ..."
    fi
    while [[ -z "''${NODE// }" ]]; do
       echo -n "."
       sleep 10
       NODE=$(squeue -hj $JOBID -O nodelist )
    done

    # Wait the job to finish
    echo  " "
    echo -n "    WAITING THE JOB TO FINISH"
    STATE="R"
    while [[ "''${STATE:0:1}" == "R" ]]; do
       echo -n "."
       sleep 10
       STATE=$(squeue -hj $JOBID -O statecompact )
    done
    echo  " "
    set -x
    scontrol show JobId=$JOBID || true
    set +x
  ''
