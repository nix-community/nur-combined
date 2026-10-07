{
  lib,
  fetchFromGitHub,
  python3Packages,
  dnsmasq,
  android-tools,
  e2fsprogs,
  gawk,
  getent,
  gobject-introspection,
  fuse2fs,
  fuse-overlayfs,
  fuse3,
  gtk3,
  kmod,
  lxc,
  iproute2,
  iptables,
  nftables,
  util-linux,
  wrapGAppsHook3,
  wl-clipboard,
  nix-update-script,
  callPackage,
  withNftables ? true,
}:

# miodroid: a fork of waydroid designed to coexist alongside an upstream
# waydroid installation. All paths, D-Bus names, systemd service names and
# the LXC container name are scoped to "miodroid" / "miodro" so the two
# can run simultaneously without conflicts.
#
# Patch series (`patches` below, all written against upstream waydroid 1.6.3):
#   0004 – Android 13-16 / LineageOS 20-23 vendor detection
#           upstream PR: https://github.com/waydroid/waydroid/pull/2393
#   0005 – multi-instance support (--instance / -I)
#           upstream PR: https://github.com/waydroid/waydroid/pull/1990
#   0006 – rootless container manager
#
#   0007 – experimental rootless mode: per-user fuse mounts, idmap, image growth
#
# The rebrand is not a patch: 0004-0006 stay valid only because they apply to
# pristine upstream code, so the waydroid -> miodroid substitutions happen in
# postPatch *after* they are applied.  0007 edits the rebranded code (miodroid
# paths, the multi-instance helpers) and therefore runs at the very end of
# postPatch instead of in the list above.
#
# postPatch is deliberately merciless: the whitespace-free `grep -q` at the end
# of each rebrand block fails the build when upstream changes the line a rule
# depends on.  Do not "fix" a failure by adding --fuzz back to patchFlags; a
# hunk that does not apply exactly is a hunk that silently disappears.
#
# Community Android 16 images:  miodroid init -c <system> -v <vendor> -r lineage
# See: https://github.com/supechicken/waydroid-builds

let
  package = python3Packages.buildPythonApplication rec {
    pname = "miodroid";
    version = "1.6.3";
    pyproject = false;

    src = fetchFromGitHub {
      owner = "waydroid";
      repo = "waydroid";
      tag = version;
      hash = "sha256-1YYNSqIW+0vkCRZ+vemqu0CXhU6aOGvpMzdswvlAc84=";
    };
    patches = [
      ./patches/0004-android16-vendor-detection.patch
      ./patches/0005-multi-instance-support.patch
      ./patches/0006-rootless-container-manager.patch
      ./patches/0007-rootless-mode.patch
      ./patches/0008-rebrand.patch
    ];
    patchFlags = [ "-p1" ];

    postPatch = ''
      # ── Rebrand waydroid → miodroid ────────────────────────────────────────
      # Rebranding is now done via patches/0008-rebrand.patch.
      chmod +x data/scripts/miodroid-net.sh
      #
      # Both sides of the interface name contract: fail the build instead of
      # shipping a renamed script whose named instances are silently offline.
      grep -q 'f"miodroid0{get_suffix_dash()}"' tools/helpers/instance.py
      grep -q 'iface_name="miodroid0-''${WAYDROID_INSTANCE}"' data/scripts/miodroid-net.sh

      # "patch" leaves these behind when it has to apply a hunk with fuzz.
      # They are dead weight in the package and a sign that a patch drifted.
      find . -name "*.orig" -delete

    '';

    nativeBuildInputs = [
      gobject-introspection
      wrapGAppsHook3
    ];

    buildInputs = [
      gtk3
    ];

    propagatedBuildInputs = with python3Packages; [
      dbus-python
      gbinder-python
      pyclip
      pygobject3
    ];

    dontUseSetuptoolsBuild = true;
    dontUsePipInstall = true;
    dontWrapPythonPrograms = true;
    dontWrapGApps = true;

    installFlags = [
      "PREFIX=${placeholder "out"}"
      "USE_SYSTEMD=0"
      "SYSCONFDIR=${placeholder "out"}/etc"
    ]
    ++ lib.optional withNftables "USE_NFTABLES=1";

    postInstall = ''
            # The Makefile installs bin/miodroid as a symlink to the Python entry
            # point.  Put the instance wrapper in its place:
            # without it `miodroid -I <name>` hands the name to miodroid-net.sh while
            # get_inet_name() and get_work_dir() keep returning the default instance,
            # so the script bails out and the instance silently loses its network.
            rm -f $out/bin/miodroid
            cat << 'EOF2' > $out/bin/miodroid
      #!/bin/sh
      INSTANCE=""
      PREV=""
      for arg in "$@"; do
        if [ "$PREV" = "-I" ] || [ "$PREV" = "--instance" ]; then
          INSTANCE="$arg"
          break
        fi
        case "$arg" in
          -I*) INSTANCE="''${arg#-I}"; break ;;
          --instance=*) INSTANCE="''${arg#--instance=}"; break ;;
        esac
        PREV="$arg"
      done
      if [ -n "$INSTANCE" ]; then
        export MIODROID_INSTANCE="$INSTANCE"
      fi
      exec "@entrypoint@" "$@"
      EOF2
            chmod 0755 $out/bin/miodroid
            substituteInPlace $out/bin/miodroid \
              --replace-fail '@entrypoint@' "$out/lib/miodroid/waydroid.py"
    '';

    preFixup = ''
      makeWrapperArgs+=("''${gappsWrapperArgs[@]}")

      patchShebangs --host $out/lib/miodroid/data/scripts
      wrapProgram $out/lib/miodroid/data/scripts/miodroid-net.sh \
        --prefix PATH ":" ${
          lib.makeBinPath [
            dnsmasq
            getent
            iproute2
            (if withNftables then nftables else iptables)
          ]
        }

      wrapPythonProgramsIn $out/lib/miodroid/ "${
        lib.concatStringsSep " " (
          [
            "$out"
          ]
          ++ propagatedBuildInputs
          ++ [
            gawk
            kmod
            lxc
            fuse2fs
            android-tools
            e2fsprogs
            fuse-overlayfs
            fuse3
            util-linux
            wl-clipboard
          ]
        )
      }"

    '';

    meta = {
      description = "Miodroid: a rebranded Waydroid fork for parallel installation (container-based Android on Linux)";
      mainProgram = "miodroid";
      homepage = "https://github.com/waydroid/waydroid";
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.linux;
      maintainers = [ ];
      # Credits to Valve Lepton project (https://gitlab.steamos.cloud/frame-public/lepton) for rootless architecture
    };
  };
in
package.overrideAttrs (old: {
  passthru =
    let
      tests = callPackage ./tests.nix { inherit package; };
    in
    (old.passthru or { })
    // {
      updateScript = nix-update-script { };
      tests = (old.passthru.tests or { }) // {
        nixos = tests.rootful;
        nixos-rootless = tests.rootless;
      };
    };
})
