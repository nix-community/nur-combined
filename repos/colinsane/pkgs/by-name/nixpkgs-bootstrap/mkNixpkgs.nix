# XXX: this is in the bootstrap path;
# this means it has to be evaluatable using only builtins,
# though i'm free to include optional functionality (e.g. update scripts) so long as i gate it behind availability checks.
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
#VVV these may or may not be available when called VVV
  fetchzip ? builtins.fetchTarball,
  stdenv ? null,
  unstableGitUpdater ? null,
}:
let
  mkNixpkgs = {
    rev,
    sha256,
    branch,
    version,
  #VVV config
    localSystem ? if stdenv != null then stdenv.buildPlatform.system else builtins.currentSystem,  #< not available in pure mode
    system ? if stdenv != null then stdenv.hostPlatform.system else localSystem,
  }@args: let
    src' = fetchzip ({
      url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
      # nixpkgs' update-source-version (updateScript) finds the new hash by specifying this hardcoded bogus hash
      # and then checking the error messages.
      # but that doesn't work for builtins; instead we leave the builtin hash unspec'd,
      # and let eval progress to where pkgs.fetchzip exists and errors.
    } // (if sha256 != "sha256-AzH1rZFqEH8sovZZfJykvsEmCedEZWigQFHWHl6/PdE=" then { inherit sha256; } else {}));

    commonNixpkgsArgs = {
      inherit localSystem;
      # reset impurities
      config = {};
      overlays = [];
    };
    unpatchedNixpkgs = import src' commonNixpkgsArgs;

    patchedSrc = unpatchedNixpkgs.applyPatches {
      src = src';
      name = "nixpkgs-patched-uninsane";
      inherit version;
      patches = unpatchedNixpkgs.callPackage ./patches.nix { };
      # skip applied patches
      prePatch = ''
        realpatch=$(command -v patch)
        patch() {
           OUT=$($realpatch "$@") || echo "$OUT" | grep "Skipping patch" -q
        }
      '';
    };

    nixpkgsArgs = commonNixpkgsArgs // {
      config = {
        allowUnfree = true;  # NIXPKGS_ALLOW_UNFREE=1
        allowBroken = true;  # NIXPKGS_ALLOW_BROKEN=1
      };
    } // (if (system != localSystem) then {
      # XXX(2023/12/11): cache.nixos.org uses `system = ...` instead of `hostPlatform.system`, and that choice impacts the closure of every package.
      # so avoid specifying hostPlatform.system on non-cross builds, so i can use upstream caches.
      crossSystem = system;
    } else {});
    nixpkgs = import "${patchedSrc}" nixpkgsArgs;
  in
    # N.B.: this is crafted to allow `nixpkgs.FOO` from other nix code
    # AND `nix-build -A nixpkgs`
    patchedSrc.overrideAttrs (base: {
      # attributes needed for update scripts
      inherit version;
      pname = "nixpkgs";
      passthru = (base.passthru or {}) // nixpkgs // {
        # override is used to configure hostPlatform higher up.
        override = overrideArgs: mkNixpkgs (args // overrideArgs);

        # N.B.: src has to be specified in passthru, not the outer scope, so as to take precedence over the nixpkgs `src` package
        src = {
          # required by unstableGitUpdater
          gitRepoUrl = "https://github.com/NixOS/nixpkgs.git";
          inherit rev;
        } // src';

        # required so that unstableGitUpdater can know in which file the `rev` variable can be updated in.
        meta.position = let
          position = builtins.unsafeGetAttrPos "rev" args;
        in
          "${position.file}:${toString position.line}";

        # while we could *technically* use `nixpkgs.<...>` updateScript
        # that can force maaany rebuilds on staging/staging-next.
        # updateScript = nix-update-script {
        #   extraArgs = [ "--version=branch=${branch}" ];
        # };
        updateScript = unstableGitUpdater {
          # else the update script tries to walk 10000's of commits to find a tag
          hardcodeZeroVersion = true;
          inherit branch;
        };
      };
    })
  ;
in
  mkNixpkgs
