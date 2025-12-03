# XXX: this is in the bootstrap path;
# this means it has to be evaluatable using only builtins,
# though i'm free to include optional functionality (e.g. update scripts) so long as i gate it behind availability checks.
#
# some considerations in order to keep this file compatible with updateScripts (e.g. `scripts/update sane.nixpkgs-bootstrap.master`):
# - <repo:nixos/nixpkgs:pkgs/common-updater/scripts/update-source-version>, used by `{git,unstableGit}updater`,
#   updates the src attributes (rev, url, etc), then attempts to `nix-build` the package, discovers the new
#   source hash by scraping the nix error, "hash mismatch in fixed-output derivation ...", then patches in the new hash.
# - this logic only works for nixpkgs fetchers -- NOT (necessarily) the nix builtin fetcher.
# - this process requires that attrs like `sane.nixpkgs-bootstrap.master.src` be _evaluatable_, even if
#   e.g. the `patches` i intend to apply don't cleanly apply to the new rev.
#
# this leads to the following updateScript-aware implementation:
# 1. impure.nix evaluates (approximately) to `(import nixpkgs-bootstrap/master.nix { ... }).pkgs.extend (overlays)`.
#   - that's `(mkNixpkgs { branch = "master", rev = ... }).pkgs.extend (overlays)`
# 2. we can't guarantee that `sane.nixpkgs-bootstrap.master.src` is actually evaluatable, when updating the bootstrap,
#    however we _can_ detect that the bootstrap is being updated during eval of `mkNixpkgs`(*),
#    and if so force a failure which the update script will parse identically as if the actual `sane.nixpkgs-bootstrap.master.src` had failed to build.
# (*) `mkNixpkgs` can detect that an updateScript for `foo.src` is running by testing `foo.src.hash`
#     against the sentinel value which `update-source-version` assigns during updates.
#
#
# branch workflow:
# - daily:
#   - nixos-unstable cut from master after enough packages have been built in caches.
# - every 6 hours:
#   - master auto-merged into staging and staging-next
#   - staging-next auto-merged into staging.
# - manually, approximately once per month:
#   - staging-next is cut from staging.
#   - staging-next merged into master.
#
# which branch to source from?
# - nixos-unstable: for everyday development; it provides good caching
# - master: temporarily if i'm otherwise cherry-picking lots of already-applied patches
# - staging-next: if testing stuff that's been PR'd into staging, i.e. base library updates.
# - staging: maybe if no staging-next -> master PR has been cut yet?
{
#VVV these may or may not be available when called. VVV
  applyPatches ? null,
  fetchzip ? null,
  nixpkgs-bootstrap-updater ? null,
  stdenv ? null,
  vendorPatch ? null,
#VVV config
  localSystem ? if stdenv != null then stdenv.buildPlatform.system else builtins.currentSystem,  #< not available in pure mode
  system ? if stdenv != null then stdenv.hostPlatform.system else localSystem,
}:
let
  optionalAttrs = cond: attrs: if cond then attrs else {};
  # nixpkgs' update-source-version (updateScript) calculates the new hash for a `src` by specifying this hardcoded bogus hash and then attempting to realize it.
  sentinelSha256 = "sha256-AzH1rZFqEH8sovZZfJykvsEmCedEZWigQFHWHl6/PdE=";
  fetchBootstrap = { url, pname, version, ... }@args: {
    # N.B. `outPath` is a special attr name which nix consults when coercing an attrset to a string.
    outPath = builtins.fetchTarball ({
      inherit url;
      name = if version != "" then "${pname}-${version}" else pname;
    } // (
      builtins.removeAttrs args [ "url" "pname" "version" ]
    ));
    inherit pname version;
  };

  mkNixpkgs = {
    branch,
    rev ? "",
    sha256 ? "",
    version ? "",
  }@args: let
    url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
    pname = "nixpkgs-${branch}";
    commonNixpkgsArgs = {
      inherit localSystem;
      # reset impurities
      config = {};
      overlays = [];
    };
    # first, fetch the unpatched nixpkgs src:
    src' = if fetchzip != null then
      fetchzip { inherit url pname version sha256; }
    else if sha256 != "" && sha256 != sentinelSha256 then
      # fetch nixpkgs using `builtins.fetchTarball`.
      # a proper bootstrap would be to return `(import (fetchBootstrap src) {}).fetchzip src`.
      # this would be more immune to bugs like <https://github.com/NixOS/nixpkgs/pull/404702#issuecomment-2861798821>,
      # however it would force an extra eval of nixpkgs for _every_ user invocation of `nix`.
      fetchBootstrap { inherit url pname version sha256; }
    else
      # we don't know the hash for our nixpkgs.
      # likely that an updateScript is running, and attempting to discover the new hash.
      # then, use an impure bootstrap to fetch nixpkgs, and then invoke that nixpkgs' `fetchzip`.
      # this is expected to fail, however by failing inside a nixpkgs' fetcher, we allow the updateScript to complete.
      let
        impureNixpkgsSrc = fetchBootstrap { inherit url pname version; };
        impureNixpkgs = import impureNixpkgsSrc commonNixpkgsArgs;
      in
        impureNixpkgs.fetchzip { inherit url pname version sha256; }
    ;

    unpatchedNixpkgs = import src' commonNixpkgsArgs;

    applyPatches' = if applyPatches != null then applyPatches else unpatchedNixpkgs.applyPatches;
    stdenv' = if stdenv != null then stdenv else unpatchedNixpkgs.stdenv;
    vendorPatch' = if vendorPatch != null then vendorPatch else import ./vendorPatch { stdenv = stdenv'; vendor-patch-updater = null; };

    srcMeta = (src'.meta or {}) // {
      position = let
        position = builtins.unsafeGetAttrPos "rev" args;
      in
        "${position.file}:${toString position.line}";
    };

    patches = import ./patches { vendorPatch = vendorPatch'; };

    patchedSrc = applyPatches' {
      name = "nixpkgs-${branch}-sane";
      inherit version;

      src = {
        # required by unstableGitUpdater
        gitRepoUrl = "https://github.com/NixOS/nixpkgs.git";
        inherit rev;
      } // src' // {
        meta = srcMeta;
        passthru = (src'.passthru or {}) // {
          # required so that unstableGitUpdater can know in which file the `rev` variable can be updated in:
          # N.B.: declare `meta` in passthru instead of toplevel, so that it takes precedence over the default calculated by `mkDerivation`/`applyPatches`
          meta = srcMeta;
          # for convenience:
          pkgs = nixpkgs;
          unpatchedSrc = src';
          patches = patches;
        } // optionalAttrs (nixpkgs-bootstrap-updater != null) {
          updateScript = nixpkgs-bootstrap-updater.makeUpdateScript {
            inherit branch;
          };
        };
      };

      patches = builtins.attrValues patches;
      # skip applied patches
      prePatch = ''
        realpatch=$(command -v patch)
        patch() {
           OUT=$($realpatch "$@") || echo "$OUT" | grep "Skipping patch" -q
        }
      '';
    };

    elaborate = unpatchedNixpkgs.lib.systems.elaborate;
    isCross = !(unpatchedNixpkgs.lib.systems.equals (elaborate system) (elaborate localSystem));

    nativeNixpkgsArgs = commonNixpkgsArgs // {
      config = {
        allowUnfree = true;  # NIXPKGS_ALLOW_UNFREE=1
        allowBroken = true;  # NIXPKGS_ALLOW_BROKEN=1
        allowUnsupportedSystem = true;  # NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1
      };
    };
    nixpkgsArgs = nativeNixpkgsArgs // optionalAttrs isCross {
      # XXX(2023/12/11): cache.nixos.org uses `system = ...` instead of `hostPlatform.system`, and that choice impacts the closure of every package.
      # so avoid specifying hostPlatform.system on non-cross builds, so i can use upstream caches.
      crossSystem = system;
      # config = nativeNixpkgsArgs.config // optionalAttrs (system.isStatic && system.hasSharedLibraries) {
      #   # default nixpkgs' behavior when `isStatic` is to _never_ build shared objects.
      #   replaceCrossStdenv = { buildPackages, baseStdenv }: baseStdenv.override (old: {
      #     # mkDerivationFromStdenv = _stdenv: args: baseStdenv.mkDerivation (args // {
      #     #   dontAddStaticConfigureFlags = args.dontAddStaticConfigureFlags or true;
      #     # });
      #     # mkDerivationFromStdenv = _stdenv: args: (baseStdenv.mkDerivation args).overrideAttrs (prev: {
      #     #   dontAddStaticConfigureFlags = prev.dontAddStaticConfigureFlags or true;
      #     #     # dontAddStaticConfigureFlags = args.dontAddStaticConfigureFlags or true;
      #     # });
      #     mkDerivationFromStdenv = _stdenv: args: (baseStdenv.mkDerivation args).overrideAttrs (prev: {
      #       # this is not wholly correct; goal is to undo some effects of pkgs/stdenv/adapters.nix' makeStatic
      #       # to build BOTH .a and .so files (but default to static)
      #       configureFlags = buildPackages.lib.remove "--disable-shared" (prev.configureFlags or args.configureFlags or []);
      #       # cmakeFlags = buildPackages.lib.remove "-DBUILD_SHARED_LIBS:BOOL=OFF" (
      #       #   buildPackages.lib.remove "-DCMAKE_SKIP_INSTALL_RPATH=On" (prev.cmakeFlags or args.cmakeFlags or [])
      #       # );
      #     });
      #   });
      # };
    };
    nixpkgs = import patchedSrc nixpkgsArgs;
  in
    patchedSrc
  ;
in
  mkNixpkgs
