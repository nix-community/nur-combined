{
  darling,
  clangStdenv,
  fetchgit,
  git,
  gnused,
  lib,
  nix-update-script,
  writeShellApplication,
}:

# VibeDarling is a development fork of Darling. It is a full tree of its own
# (its submodules point at VibeDarling forks of the Darling components), so it
# reuses the darling expression for everything except the differences below.
#
# Unlike upstream, the fork vendors prebuilt Swift runtime dylibs through Git
# LFS in src/external/swift. They are installed and passed to ld64 through
# -dylib_file, so the source must be fetched with LFS enabled; fetchFromGitHub
# cannot download LFS payloads.
darling.overrideAttrs (old: {
  pname = "vibedarling";
  version = "0.1.20260921-unstable-2026-11-06";

  src = fetchgit {
    url = "https://github.com/VibeDarling/darling";
    rev = "b456e0f1b3114c0b6f2e89e11fcaf371a20dc63c";
    fetchSubmodules = true;
    fetchLFS = true;
    hash = "sha256-5sqipDW8ww/Q+MFH+AafZzqOvkY2Fw11AHCzSnBdURU=";
  };

  # The fork's darling-dmg revision needs the FUSE 3 port rebased, and its
  # darlingserver revision no longer has tests/CMakeLists.txt, so the base
  # host-test-headers patch has no target here.
  patches = [
    ./fuse3.patch
    ../../da/darling/mslc-include-without-metal.patch
    ../../da/darling/cametal-layer-dynamic-stub.patch
  ];

  postPatch =
    # The fork predates the ICU 78 submodule and ships a working
    # icudt66l.dat.xz itself, so drop the base package's ICU 78 data injection.
    lib.concatStringsSep "\n" (
      builtins.filter (line: !(lib.hasInfix "icudt78l" line)) (lib.splitString "\n" old.postPatch)
    )
    + ''
      # The fork put the FUSE support behind DARLING_DMG_ENABLE_FUSE (enabled
      # below) and still links the old FUSE 2 libraries there.
      substituteInPlace src/external/darling-dmg/CMakeLists.txt \
        --replace-fail 'pkg_check_modules(FUSE REQUIRED fuse)' \
                       'pkg_check_modules(FUSE REQUIRED fuse3)' \
        --replace-fail 'include_directories(''${FUSE_INCLUDE_DIRS})' \
                       'include_directories(''${FUSE_INCLUDE_DIRS} ''${FUSE_INCLUDEDIR})' \
        --replace-fail 'wrap_elf(fuse libfuse.so)' \
                       'wrap_elf(fuse libfuse3.so)' \
        --replace-fail 'target_link_libraries(darling-dmg -lfuse dmg)' \
                       'target_link_libraries(darling-dmg -lfuse3 dmg)'
    '';

  # The fork builds its host tools in a nested CMake project and searches for
  # an unwrapped clang, which cannot link host binaries under Nix. Point it at
  # the wrapped compiler instead.
  cmakeFlags = old.cmakeFlags ++ [
    "-DDARLING_DMG_ENABLE_FUSE=ON"
    "-DHOST_CC=${clangStdenv.cc}/bin/clang"
    "-DHOST_CXX=${clangStdenv.cc}/bin/clang++"
  ];

  # The fork's CoreAudio embeds -DINSTALL_PREFIX as a last-resort PulseAudio
  # prefix (Termux support), so its framework binary legitimately points at
  # the package's own store path. Keep the audit for everything else.
  postFixup =
    builtins.replaceStrings
      [ ''| grep -vxF "$out/libexec/darling/Library/Developer/DarlingCLT/usr/bin/ld" || true'' ]
      [
        ''
          | grep -vxF "$out/libexec/darling/Library/Developer/DarlingCLT/usr/bin/ld" \
          | grep -vxF "$out/libexec/darling/System/Library/Frameworks/CoreAudio.framework/Versions/A/CoreAudio" || true
        ''
      ]
      old.postFixup;

  passthru = old.passthru // {
    # This tree pulls every submodule and the Swift runtime through Git LFS.
    # Reuse darling's interrupted-fetch handling: nix-update moves the
    # revision before fetching the hash, so a dropped connection would
    # otherwise leave a stale hash with no version change to trigger a retry.
    updateScript = writeShellApplication {
      name = "update-vibedarling";
      runtimeInputs = [
        git
        gnused
      ];
      text = ''
        export UPDATE_NIX_ATTR_PATH="vibedarling"

        root="$(git rev-parse --show-toplevel)"
        package="$root/by-name/vi/vibedarling/package.nix"
        # The fork's own release base is not derivable from the branch name, so
        # read it from the committed package; that also stops a mangled working
        # copy from propagating into the next update.
        base="$(git -C "$root" show HEAD:by-name/vi/vibedarling/package.nix | sed -nE 's/^  version = "([^-]+)-unstable-.*/\1/p')"

        nix-update() {
          ${
            lib.escapeShellArgs (nix-update-script {
              extraArgs = [ "--version=branch" ];
            })
          } "$@"
        }

        update_hash() {
          ${
            lib.escapeShellArgs (nix-update-script {
              extraArgs = [ "--version=skip" ];
            })
          } "$@"
        }

        update_hash_retry() {
          local attempt
          for attempt in 1 2 3; do
            if update_hash "$@"; then
              return 0
            fi
            if [ "$attempt" -lt 3 ]; then
              echo "update-vibedarling: hash recheck failed (attempt $attempt), retrying" >&2
              sleep $((attempt * 10))
            fi
          done
          return 1
        }

        if ! nix-update "$@"; then
          echo "nix-update failed; updating the hash for the pinned revision" >&2
          update_hash_retry || true
          exit 1
        fi

        update_hash_retry "$@"

        # `nix-update --version=branch` derives the version base from pname,
        # losing the fork's release base. Keep <base>-unstable-<date>.
        version="$(sed -nE 's/^  version = "([^"]+)";/\1/p' "$package")"
        sed -i -E "s|^  version = \"[^\"]+\";|  version = \"$base-unstable-''${version##*unstable-}\";|" "$package"
      '';
    };
  };

  meta = old.meta // {
    description = "Darling fork (VibeDarling) with Swift runtime and app compatibility work";
    homepage = "https://github.com/VibeDarling/darling";
    changelog = "https://github.com/VibeDarling/darling/releases";
    maintainers = (old.meta.maintainers or [ ]) ++ [ lib.maintainers.mio ];
  };
})
