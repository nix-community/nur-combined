{
  lib,
  buildGoApplication,
  libffi,
  source,
  stdenv,
}:
import ../manboster/package.nix {inherit lib buildGoApplication libffi stdenv;} {
  inherit source;
  modules = ./gomod2nix.toml;
  version = "0-unstable-${source.date}";
  channel = "canary";
  # `dev` moved the ldflag vars from `internal/config` to `internal/release`.
  releasePkg = "internal/release";
  # A branch snapshot has no meaningful semver; keep upstream's literal.
  versionFile = null;
}
