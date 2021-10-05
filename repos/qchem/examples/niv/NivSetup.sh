#! /usr/bin/env nix-shell
#! nix-shell -i bash -p niv

# EXECUTE THIS SCRIPT BEFORE USING THE NIX EXPRESSIONS!

# Niv will be used to pin dependencies. It allows to
# update and modify pinned dependencies conveniently
# from a CLI and is especially useful, when multiple
# dependencies are updated often.

# Initialise niv expressions in ./nix
# ./nix/sources.nix is some glue for nix to make use
# of ./nix/sources.json, which keeps track of the
# dependencies. Both files should never be edited
# manually.
niv init

# Niv initialises per default a stable release branch
# from nixos and the niv sources themselves. We do not
# need the upstream niv sources and use niv from nixpkgs
# instead. Therefore we drop the niv sources, using niv
# itself.
niv drop niv

# Modify the 'nixpkgs' sources, which point by default to
# some old nixos channel. We would like to use
# nixpkgs-unstable instead. 'niv -b' allows to switch
# the branch of a git repository, that niv follows.
niv modify nixpkgs -b nixpkgs-unstable

# To add another source from GitHub, we can use niv
# shortcuts: owner/repo-name
# By default, the repo-name will be importable from sources.nix.
# In this case 'NixOS-QChem' would be another import from
# 'sources.nix'.
niv add markuskowa/NixOS-QChem

# To get an overview about the current sources you can also use
# niv.
niv show

# Updates in the tracking branches of the sources can be done
# with a simple:
niv update
