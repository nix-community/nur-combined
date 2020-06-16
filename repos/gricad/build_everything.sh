#!/bin/bash
# Script to build every package (excepted non public packages) of this repository
# to populate a public binary cache (especially the one used by travis)

export LANG=C

packages="hello gerris irods irods-icommands hp2p obitools3 plplot openmpi openmpi1 openmpi2 openmpi2-opa openmpi2-ib openmpi3 openmpi4 petscComplex petscReal udocker arpackNG gmt szip mpi-ping hoppet applgrid stacks messer-slim fate migrate gdl fftw3 zonation-core scotch-mumps suitesparse hpl"
packages_sandbox_disabled="singularity"
broken="trilinos lhapdf59 bagel"
n_cores=10
channels="https://github.com/NixOS/nixpkgs/archive/nixos-20.03.tar.gz https://github.com/NixOS/nixpkgs/archive/nixos-19.09.tar.gz"


build () {
  for p in $1
  do
	nix-build --cores $n_cores --arg pkgs 'import <nixpkgs> {}' -A $p
	if [ $? -ne 0 ]
	then
		echo -e "\nERROR: Build of $p into $c failed!" >&2
		exit 1
	fi
  done
}

# Build packages (with sandboxing on)
perl -pi -e "s/sandbox = false/sandbox = true/" ~/.config/nix/nix.conf
for c in $channels
do
	export NIX_PATH="nixpkgs=$c"
	build "$packages"
done

# Build packages that need sandboxing disabled
perl -pi -e "s/sandbox = true/sandbox = false/" ~/.config/nix/nix.conf
for c in $channels
do
	export NIX_PATH="nixpkgs=$c"
        build "$packages_sandbox_disabled"
done
perl -pi -e "s/sandbox = false/sandbox = true/" ~/.config/nix/nix.conf

