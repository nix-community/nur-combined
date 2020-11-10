{ writeShellScriptBin } :

{ name
# slurm license name
, license
# name of wrapper executable
, exe
# program to run
, runProg
} :

writeShellScriptBin exe ''
  if [ -z "$SLURM_JOB_ID" ]; then
    echo "${name} can only be run in a slurm environment"
    echo
    echo "Don't forget to check out a license by adding '-L ${license} to srun/sbatch/etc."
    exit
  fi

  licName="${license}"

  lics=$(scontrol show job $SLURM_JOB_ID | grep Licenses | sed 's/.*Licenses=\(.*\) .*/\1/')

  licsFound=$(echo "$lics"x | grep -e "''${licName}x")

  if [ -n "$licsFound" ]; then
    echo "Licenses checked out. Running ${name}..."
    ${runProg} $@
  else
    echo "No ${name} license checked out. Aborting!"
  fi
''

