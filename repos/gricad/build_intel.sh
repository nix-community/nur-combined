#!/bin/bash
# This script aims to build the intel-compilers packages on a host that has an
# official install of those compilers (into /home/scratch). The host then can
# be a private binary-cache (using nix-serve).
# The script should be ran daily by crontab, into the home of a user, just after a 
# run of the garbage collector, and a checkout of this repository. 
# This way, an up-to-date version is available against the specified NIX releases 
# (channels variable)

export LANG=C

packages="intel-compilers-2018 intel-compilers-2019 intel-oneapi"
# Use the following once to populate cache with older versions
#packages="intel-compilers-2019 intel-compilers-2018 intel-compilers-2017"

channels="channel:nixos-21.05 channel:nixos-21.11 channel:nixos-22.05"

build () {
  for p in $1
  do
	nix-build --arg pkgs 'import <nixpkgs> {}' -A $p
	if [ $? -ne 0 ]
	then
		echo -e "\nERROR: Build of $p into $c failed!" >&2
		exit 1
	fi
  done
}

# Build packages
perl -pi -e "s/sandbox = true/sandbox = false/" ~/.config/nix/nix.conf
for c in $channels
do
    export NIX_PATH="nixpkgs=$c"
    for p in $packages
    do
        build $p	
        # Install the package in a profile so that it is not garbage collected
        nix-env --switch-profile $NIX_USER_PROFILE_DIR/$p-`basename $c .tar.gz`
        nix-env -i ./result
    done
done
perl -pi -e "s/sandbox = true/sandbox = true/" ~/.config/nix/nix.conf
