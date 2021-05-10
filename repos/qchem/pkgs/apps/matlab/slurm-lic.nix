writeShellScriptBin "matlab" ''
  if [ -z "$SLURM_JOB_ID" ]; then
    echo "MATLAB can only be run in a slurm environment"
    echo
    echo "Don't forget to check out a license by adding '-L matlab to srun/sbatch/etc."
    exit
  fi

  licName="matlab"

  lics=$(scontrol show job $SLURM_JOB_ID | grep Licenses | sed 's/.*Licenses=\(.*\) .*/\1/')

  licsFound=$(echo "$lics"x | grep -e "''${licName}x")

  if [ -n "$licsFound" ]; then
    echo "Licenses checked out. Running MATLAB..."
    ${matlabEnv}/bin/matlab "$@"
  else
    echo "No MATLAB license checked out. Aborting"
  fi
''
