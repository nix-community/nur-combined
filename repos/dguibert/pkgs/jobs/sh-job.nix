{
  stdenvNoCC,
  lib,
  writeScript,
  runCommand,
}: {
  name,
  script ? "",
  buildInputs ? [],
  scratch ? null,
  log ? true,
  ...
} @ args: let
  define_job_basename_sh = name: ''export job_out=$(basename $out); export job_basename=${name}-''${job_out:0:12}'';
  job = writeScript "${name}.sh" ''
    #!${stdenvNoCC.shell}

    source ${stdenvNoCC}/setup
    set -ue -o pipefail
    runHook jobSetup
    set -x
    ${script}
    set +x
    runHook jobDone
    echo 'done'
  '';
  extraArgs = removeAttrs args ["name" "buildInputs" "outputs" "script" "scratch"];
  fixed = builtins.hasAttr "outputHash" args;
in
  builtins.trace extraArgs
  runCommand
  name (extraArgs
    // {
      inherit buildInputs;
      outputs =
        ["out"]
        ++ lib.optional (!fixed && log) "log"
        ++ lib.optional (!fixed && (scratch != null)) "scratch";
    }) ''
    log_=log
    ${lib.optionalString log ''
      log_=$log
    ''}
    failureHooks+=(_benchFail)
    _benchFail() {
      cat $log_
    }
    set -xuef -o pipefail
    mkdir $out
    ${define_job_basename_sh name}
    ${lib.optionalString (scratch != null) ''
      scratch_="${scratch}/$job_basename"
      mkdir -p $scratch_; cd $scratch_
      ${lib.optionalString (!fixed) ''ln -s "$scratch_" $scratch''}
    ''}
    ${job} 2>&1 | tee $log_
    echo "job has run"
    set +x
  ''
