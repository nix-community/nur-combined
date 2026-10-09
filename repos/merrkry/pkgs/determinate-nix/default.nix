{
  lib,
  pkgs,
  callPackage,
  fetchFromGitHub,
  source ? callPackage ./source.nix { },
  githubReleaseUpdater ? callPackage ../../lib/github-release-updater.nix { },
}:

let
  inherit (source) version src;
  # Fetch packaging at evaluation time without realising the source derivation.
  upstreamSource = builtins.fetchTarball {
    inherit (src) url;
    sha256 = src.outputHash;
  };
  lock = builtins.fromJSON (builtins.readFile "${upstreamSource}/flake.lock");
  gcSource = lock.nodes.${lock.nodes.root.inputs.bdwgc}.locked;
  dependencies = import "${upstreamSource}/packaging/dependencies.nix" {
    # Keep the release's Boost configuration on nixpkgs' compatible version.
    pkgs = pkgs // {
      inherit (pkgs.nixDependencies) boost;
    };
    inherit (pkgs) stdenv;
    inputs.bdwgc = fetchFromGitHub {
      inherit (gcSource) owner repo rev;
      hash = gcSource.narHash;
    };
  };
  upstreamComponents = import "${upstreamSource}/packaging/components.nix" {
    inherit lib pkgs src;
    officialRelease = true;
    maintainers = with lib.maintainers; [ merrkry ];
  };

  # Import the release's packaging so dependency flags and patches follow it.
  components = lib.makeScope pkgs.newScope (
    final:
    let
      packages = upstreamComponents final;
    in
    dependencies final
    // packages
    // {
      # Reuse nixpkgs' existing Wasmtime C API build.
      inherit (pkgs) wasmtime;

      nix-store = packages.nix-store.overrideAttrs {
        # The source already contains a build/ directory, as in nixpkgs' Nix.
        mesonBuildDir = "meson-build-dir";
      };

      nix-functional-tests = packages.nix-functional-tests.overrideAttrs (old: {
        # --as-needed drops the consumer's direct libnixutil dependency and can
        # load libstdc++ first. GCC's -Bsymbolic-functions still binds calls to
        # libnixutil's __cxa_throw hook, whose RTLD_NEXT lookup then fails and
        # aborts before main(). Keep the direct dependency to preserve load order.
        # https://github.com/DeterminateSystems/nix-src/blob/v3.23.1/nix-meson-build-support/common/cxa-throw/interpose-cxa-throw.cc#L14-L16
        # Remove this workaround once the hook supports either library load order.
        #
        # This only fixes the functional test's consumer. The CLI and daemon
        # can replace nix.package, but external C++ consumers linking these
        # libraries may need -Wl,--no-as-needed too. Their link flags are not
        # changed here. The upstream release's flake package has the same limit.
        mesonFlags = (old.mesonFlags or [ ]) ++ [ (lib.mesonBool "b_asneeded" false) ];
      });
    }
  );
in
components.nix-everything.overrideAttrs (
  finalAttrs: old: {
    __structuredAttrs = true;
    strictDeps = true;

    passthru = old.passthru // {
      inherit version src components;
      packagingSource = src;
      updateScript = [
        (lib.getExe githubReleaseUpdater)
        "--owner"
        "DeterminateSystems"
        "--repo"
        "nix-src"
        "--attribute"
        "determinate-nix"
        "--tag-pattern"
        "v(\\d+\\.\\d+\\.\\d+)"
        "--"
        "--file=pkgs/determinate-nix/update.nix"
        "--override-filename=pkgs/determinate-nix/source.nix"
      ];
    };

    meta = old.meta // {
      description = "Determinate Nix package manager";
      homepage = "https://github.com/DeterminateSystems/nix-src";
      changelog = "https://github.com/DeterminateSystems/nix-src/releases/tag/v${finalAttrs.version}";
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
  }
)
