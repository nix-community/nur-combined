Using Gricad's LAMMPS-IMPI (nur.repos.gricad.lammps-impi)
=========================================================

This is lammps compiled with the Intel Oneapi MPI.

* Install:

```
# Switch to a new profile
nix-env --switch-profile $NIX_USER_PROFILE_DIR/lammps

# Install
export NIX_PATH="nixpkgs=channel:nixos-21.05"
nix-env -iA nur.repos.gricad.intel-oneapi
nix-env -iA nur.repos.gricad.lammps-impi
```

* Launch:

```
# Submit a job with 2 nodes
oarsub -I -l /nodes=2 -t devel --project test

# Run
# (supposing you've made a `git clone git@github.com:lammps/lammps.git`)
cd lammps/examples/indent
source ~/.nix-profile/setvars.sh
mpiexec -n `cat $OAR_FILE_NODES|wc -l` -f $OAR_NODE_FILE -bootstrap-exec oarsh lmp_intel_cpu_intelmpi -in in.indent
```

