#!/bin/bash

packages="hello obitools3 plplot openmpi openmpi2 openmpi2-opa openmpi2-ib openmpi3 openmpi4 petscComplex petscReal udocker arpackNG gmt szip mpi-ping singularity hoppet applgrid stacks messer-slim fate migrate gdl fftw3 zonation-core scotch-mumps"
broken="trilinos lhapdf59 bagel"
n_cores=10
channels="https://nixos.org/channels/nixos-19.09 https://nixos.org/channels/nixpkgs-unstable"


build () {
  for p in $packages
  do
	nix-build --cores $n_cores --arg pkgs 'import <nixpkgs> {}' -A $p
	if [ $? -ne 0 ]
	then
		echo -e "\nERROR: Build of $p into $c failed!" >&2
		exit 1
	fi
  done
}

for c in $channels
do
	nix-channel --add $c nixpkgs
	nix-channel --update
	build
done
