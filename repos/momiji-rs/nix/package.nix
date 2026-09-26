# The `sasso` CLI as a Nix derivation — the one this repo's `flake.nix` builds,
# and the one `nur.nix` re-exports as `nur.repos.momiji-rs.sasso`.
#
# Two derivations describe sasso to Nix, and they differ on purpose:
#
#   * this one builds the tree it lives in and takes its dependency hashes from
#     `Cargo.lock`, so it carries no hash of its own and cannot go stale: a
#     release bumps `Cargo.toml` and nothing here needs a second edit;
#   * a nixpkgs `pkgs/by-name/sa/sasso/package.nix` fetches a tagged tarball with
#     `fetchFromGitHub` and pins the vendored crates with a single `cargoHash`,
#     because that is the shape nixpkgs' update tooling (`nix-update`, and the
#     r-ryantm bot that would follow our tags) knows how to rewrite. That copy
#     lives in a nixpkgs checkout, not here — README.md beside this file records
#     where the submission stands.
#
# Keep the two in step on the parts that are judgement calls rather than
# plumbing: the license pair, the check story, and `meta`.
{
  lib,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sasso";

  # One source of truth for the version: the crate manifest. `release-wasm.yml`
  # already refuses an `npm-v*` tag that disagrees with it, so this keeps the
  # third packaging line honest by construction too.
  version = (lib.importTOML ../Cargo.toml).package.version;

  src = lib.cleanSource ../.;

  # No `cargoHash` here: each crate is fetched under the checksum `Cargo.lock`
  # already records. The lock file holds nothing but the divan/CodSpeed
  # dev-dependency tree — sasso's runtime dependency count is zero — so this
  # vendors only what `cargo test` and the benchmarks need to compile.
  cargoLock.lockFile = ../Cargo.lock;

  # The sandbox has no network, which is the environment the test suite is
  # already written for: `tests/parity.rs` shells out to dart-sass only when
  # `SASSO_PARITY=1` is set and returns early otherwise, and no other suite
  # reaches outside the build tree. So the full `cargo test` runs here — a Nix
  # build of sasso is a real check, not just a compile.
  #
  # The benchmark target is left out: `codspeed-divan-compat` compiles fine, but
  # timing anything inside a build sandbox measures the builder, not the code.
  cargoTestFlags = [
    "--lib"
    "--bins"
    "--tests"
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Pure-Rust SCSS to CSS compiler (a dart-sass alternative)";
    longDescription = ''
      sasso compiles SCSS and the indented Sass syntax to CSS with no runtime
      dependencies: no libsass, no Dart VM, no native add-ons. It passes 98.9%
      of the attempted sass-spec suite byte-for-byte against dart-sass, and
      ships as a CLI with a dart-sass-compatible command line, a Rust library,
      a C ABI, and a WebAssembly build for JavaScript build tools.
    '';
    homepage = "https://github.com/momiji-rs/sasso";
    changelog = "https://github.com/momiji-rs/sasso/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "sasso";
    # Deliberately empty in this copy: `lib.maintainers` is nixpkgs' list, and
    # naming an entry here would make the flake fail to evaluate until that
    # entry exists upstream. nixpkgs' copy carries the maintainer.
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
