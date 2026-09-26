# The NUR entry point: what `nur.repos.momiji-rs.*` resolves to.
#
# nixpkgs declined the CLI for now on its maturity criteria
# (NixOS/nixpkgs#564362) and pointed at the Nix User Repository instead. This
# file is that channel, and it is deliberately a thin adapter rather than a
# third derivation:
#
#   nur.repos.momiji-rs.sasso      ->  ./package.nix, the CLI
#   nur.repos.momiji-rs.sasso-ffi  ->  ./ffi.nix, the C ABI
#
# NUR registers a repository URL rather than a package, so its `repos.json`
# points at this tree with `"file": "nix/nur.nix"`. There is no separate
# nur-packages repo to keep in step with a release, and nothing here carries a
# hash: both derivations build the tree they live in and vendor from
# `Cargo.lock`, so a release bumps `Cargo.toml` and needs no second edit.
#
# Two constraints NUR imposes that this file has to respect:
#
#   * Take every dependency from the `pkgs` argument. NUR's evaluator allows no
#     network access at eval time — the check it documents runs with
#     `--option restrict-eval true` — so `with import <nixpkgs> {}` and the
#     `builtins.fetch*` family fail there even where they work locally.
#   * Every attribute must evaluate and build against nixpkgs unstable, or say
#     `meta.broken`. NUR re-evaluates the whole repository on each update and
#     keeps the last good revision when evaluation fails, so a break here is
#     silent: users stay pinned to an older sasso with nothing to read.
#
# NUR always passes `pkgs` itself; the default is only so that the check above
# and a plain `nix-build nix/nur.nix -A sasso` work without one, which is what
# NUR's own template does and why importing `<nixpkgs>` is allowed just here.
{
  pkgs ? import <nixpkgs> { },
}:

{
  sasso = pkgs.callPackage ./package.nix { };
  sasso-ffi = pkgs.callPackage ./ffi.nix { };
}
