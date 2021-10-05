#! /usr/bin/env nix-shell
#! nix-shell -i bash

#SBATCH --ntasks=360
#SBATCH --ntasks-per-node=36
#SBATCH --nodes=10
#SBATCH --mem=0
#SBATCH --partition=s_standard

mpiexec \
  -np $SLURM_NTASKS \
  --map-by ppr:$SLURM_TASKS_PER_NODE:node \
  nwchem input.nw > output.log
