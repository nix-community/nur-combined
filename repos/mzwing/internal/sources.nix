# nvfetcher-generated sources, post-processed for evaluation-time readers.
#
# crane reads package sources at evaluation time: it crawls the source tree
# for Cargo.toml/.cargo files (findCargoFiles) and parses Cargo.lock
# (builtins.readFile + builtins.fromTOML) in order to vendor dependencies
# and to construct its "dummy" dependency-only source. The
# rustPlatform.buildRustPackage fallback does the same for
# cargoLock.lockFile (importCargoLock). When the source is a fixed-output
# derivation (as nvfetcher generates), those reads force the source FOD to
# be realised *during evaluation*, which fails on a fresh store:
# `nix flake check --all-systems` cannot build other platforms' .drv files
# locally, and hosts configured with `max-jobs = 0` (e.g. the build
# coordinator) cannot build at all.
#
# The fix applied here: sources that are read at evaluation time are
# re-fetched with evaluation-time fetchers instead of FODs. These are
# content-addressed, allowed in pure evaluation, platform-independent, and
# need no builder:
#
#   - builtins.fetchTarball for plain archives. Unpacking the same GitHub
#     archive produces the *identical* NAR as fetchFromGitHub/fetchzip, so
#     the generated sha256 stays valid and the resulting store path is
#     exactly the one the FOD would produce (hence it remains substitutable
#     from binary caches, and builds see no difference).
#   - builtins.fetchGit for sources with git submodules (archive tarballs
#     do not contain submodule contents); pinned by `rev`.
#
# Because evaluation no longer depends on realising any derivation, flake
# evaluation works on a completely fresh store for every system.
#
# The set of sources to convert is discovered automatically (same idea as
# discover.nix): any package under ../pkgs that declares the `craneLib`
# argument is crane-built — and its buildRustPackage fallback also reads
# the source at evaluation time via importCargoLock — so its source must be
# an evaluation-time fetch. All other packages only consume their source at
# build time, where the FOD is realised as usual, so they are left alone
# (converting them would needlessly download every source during every
# evaluation, and non-tarball fetchurl sources cannot be converted at all).
{pkgs}: let
  inherit (pkgs) lib;

  raw = pkgs.callPackage ../_sources/generated.nix {};

  evalSrc = src:
    if src.fetchSubmodules or false
    then
      builtins.fetchGit {
        url = "https://github.com/${src.owner}/${src.repo}";
        inherit (src) rev;
        submodules = true;
      }
    else
      builtins.fetchTarball {
        inherit (src) url;
        sha256 = src.outputHash;
      };

  # Names of first-level package directories under ../pkgs.
  packageNames = builtins.attrNames (builtins.readDir ../pkgs);

  # Packages that read their source at evaluation time: exactly those
  # declaring the `craneLib` argument (see the comment at the top).
  evalReadSources = builtins.filter (
    name:
      builtins.hasAttr name raw
      && builtins.pathExists (../pkgs + "/${name}/default.nix")
      && builtins.functionArgs (import (../pkgs + "/${name}/default.nix")) ? craneLib
  ) packageNames;
in
  raw
  // lib.genAttrs evalReadSources (
    name: raw.${name} // {src = evalSrc raw.${name}.src;}
  )
