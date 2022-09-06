#!/bin/bash
# Script to build every package (excepted non public packages) of this repository
# to populate a public binary cache (especially the one used by travis)

export LANG=C

n_cores=10

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

###### PACKAGES FOR LATEST CHANNELS #######

c="nixos-21.05"
export NIX_PATH="nixpkgs=channel:$c"
echo $NIX_PATH
build "hello lammps-impi osu-micro-benchmarks iqtree beagle gerris obitools3 siesta openmpi openmpi1 openmpi2 openmpi2-opa openmpi2-ib openmpi3 openmpi4 fate zonation-core scotch-mumps hpl"

c="nixos-21.11"
export NIX_PATH="nixpkgs=channel:$c"
echo $NIX_PATH
build "hello lammps-impi osu-micro-benchmarks iqtree beagle gerris obitools3 siesta openmpi openmpi1 openmpi2 openmpi2-opa openmpi2-ib openmpi3 openmpi4 fate zonation-core scotch-mumps hpl"

c="nixos-22.05"
export NIX_PATH="nixpkgs=channel:$c"
echo $NIX_PATH
build "hello lammps-impi osu-micro-benchmarks iqtree beagle gerris obitools3 siesta openmpi openmpi1 openmpi2 openmpi2-opa openmpi2-ib openmpi3 openmpi4 fate zonation-core scotch-mumps hpl"

###### PACKAGES FOR OLD CHANNEL #######
c="nixos-20.03"
export NIX_PATH="nixpkgs=channel:$c"
build "hello gerris openmpi openmpi1 openmpi2 openmpi2-opa openmpi2-ib openmpi3 openmpi4 fate  zonation-core scotch-mumps hpl"

# Build packages that need sandboxing disabled
perl -pi -e "s/sandbox = true/sandbox = false/" ~/.config/nix/nix.conf
c="nixos-21.05"
export NIX_PATH="nixpkgs=$c"
build "intel-oneapi"
c="nixos-21.11"
export NIX_PATH="nixpkgs=$c"
build "intel-oneapi"
c="nixos-22.05"
export NIX_PATH="nixpkgs=$c"
build "intel-oneapi"
perl -pi -e "s/sandbox = false/sandbox = true/" ~/.config/nix/nix.conf
