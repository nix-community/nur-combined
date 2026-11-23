{
  darling,
  fetchFromGitHub,
  fetchpatch,
  lib,
  testers,
}:

# Upstream darling, plus open PRs that apply to it: libc++ filesystem symbols,
# host-directory linking and the cli-only CoreData stub. The cocotron
# compiled-nib fix is already in the pinned tree. The DESTDIR, MIG, Clang,
# cross-compiling, darpath, GLUT and MediaLibrary changes these patches used
# to carry are upstream now, as are the
# xnu, objc4, metal and cctools-port submodule bumps and the cocotron bump (X11
# backing-store leak, Info.plist, NSWorkspace openFile/openURL), convenience
# constructors, weighted fonts, window alpha, other-mouse routing, and the
# main-menu-title behavior (PR 15's idea, landed differently on the pinned
# tree). The darlingserver bump and the cocotron image-resolution key fix live
# in the base package, which needs them to build. darlingserver now keeps
# microthread state on the Thread and reads the current thread through a
# non-inlined getter (ef2f054), so the local worker-TLS patch is gone.
# Drafts, ARM64 ports,
# Docker/RPM packaging, and off-by-default options are not included. The
# cocotron text-truncation, icns, and Backup-and-Sync pulls are not included:
# the truncation search is wrong, the icns change releases an Objective-C image
# source with CFRelease, and the symbol stubs return values that would make
# every transform equal and every key look pressed.
let
  # Same owner/repo as the Darling submodules. Applied by replacing the
  # already-fetched trees; a gitlink-only patch cannot update them.
  submodule =
    {
      repo,
      rev,
      hash,
      fetchSubmodules ? false,
    }:
    fetchFromGitHub {
      owner = "darlinghq";
      name = "${repo}-src";
      inherit
        repo
        rev
        hash
        fetchSubmodules
        ;
    };

  submodules = {
    # https://github.com/darlinghq/darling/pull/1793
    "src/external/libcxx" = submodule {
      repo = "darling-libcxx";
      rev = "7d5d86d3546aea24b50c38ad25a0d141ee5271d8";
      hash = "sha256-n2zVSU03GIQNqRR1zIJWoKzIJIf2ZPq4VfvXuqUWhgI=";
    };
  };
in
darling.overrideAttrs (
  finalAttrs: old: {
    pname = "darling_patched";

    patches = (old.patches or [ ]) ++ [
      # PR 1802 rebased: link after dropping privileges, before resolving arguments.
      # https://github.com/darlinghq/darling/pull/1802
      ./link-host-directories.patch
      # https://github.com/darlinghq/darling/pull/1789
      (fetchpatch {
        name = "darling-pr-1789-coredata-cli.patch";
        url = "https://github.com/darlinghq/darling/pull/1789.diff";
        hash = "sha256-7SbPty36H0vSH/TXLVjsZhyblVbBn51HbWKTQxeqOEw=";
      })
    ];

    postPatch =
      old.postPatch
      + ''
        replace_submodule() {
          local dest=$1 src=$2
          chmod -R u+w "$dest"
          rm -rf "$dest"
          cp -a "$src" "$dest"
          # cp -a keeps the store mode, and later phases rewrite config.sub in place.
          chmod -R u+w "$dest"
        }
      ''
      + lib.concatStringsSep "\n" (
        lib.mapAttrsToList (path: src: ''
          replace_submodule ${
            lib.escapeShellArgs [
              path
              src
            ]
          }
        '') submodules
      );

    # Upstream derives OBJC_IS_DEBUG_BUILD from NDEBUG, so Release is usable.
    cmakeBuildType = "Release";

    passthru = old.passthru // {
      tests = old.passthru.tests // {
        nixos = testers.nixosTest (import ../darling/test.nix { darling = finalAttrs.finalPackage; });
      };
    };

    meta = old.meta // {
      description = "Darling with open pull requests for libc++, host-directory linking, and the CoreData stub";
    };
  }
)
