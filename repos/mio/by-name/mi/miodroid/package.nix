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
# Patch series:
#   0001 – rebrand binary / CLI prog name / config INI section / D-Bus names
#   0002 – separate data+config paths  (/var/lib/miodroid, ~/.local/share/miodroid)
#   0003 – rename LXC container + AppArmor profile + internal filenames
#   0004 – Android 13-16 / LineageOS 20-23 vendor detection
#           upstream PR: https://github.com/waydroid/waydroid/pull/2393
#   0005 – multi-instance support (--instance / -I)
#           upstream PR: https://github.com/waydroid/waydroid/pull/1990
#   0006 – rootless container manager
#   0007 – experimental rootless mode: per-user fuse mounts, idmap, no overlay
#
# Community Android 16 images:  miodroid init -c <system> -v <vendor> -r lineage
# See: https://github.com/supechicken/waydroid-builds
#
# The local patch files are applied by the patches list below; rebranding is
# then done with substitutions in postPatch. 0007 has to touch the rebranded
# code, so it is applied at the end of postPatch instead of in that list.

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
    ];
    patchFlags = [
      "-p1"
      "--fuzz=10"
    ];

    postPatch = ''
      # ── Patches 0001-0003: global rebrand waydroid → miodroid ──────────────
      #
      # Use sed across the whole tree to avoid per-file failures.
      # Order matters: rename more-specific strings first.

      # Rebrand patch 0005 after applying it, without touching Android props.
      substituteInPlace tools/helpers/instance.py \
        --replace-fail 'from tools.helpers.arguments import arguments' \
          ""
      sed -i '1i import os' tools/helpers/instance.py
      sed -i '/import tools.helpers.dbus/d' tools/helpers/__init__.py
      sed -i '/helpers.dbus.setup_policy(args)/d' tools/actions/initializer.py
      substituteInPlace tools/helpers/instance.py \
        --replace-fail 'INSTANCE_NAME = arguments("").instance' \
          'INSTANCE_NAME = os.environ.get("MIODROID_INSTANCE", "")'
      sed -i 's/id\.waydro/id.miodro/g' \
        tools/helpers/instance.py tools/helpers/ipc.py \
        tools/actions/session_manager.py
      sed -i 's/waydroid/miodroid/g' tools/helpers/instance.py
      substituteInPlace tools/helpers/instance.py \
        --replace-fail \
          'return f"miodroid{get_suffix_dash()}"' \
          'return f"miodroid0{get_suffix_dash()}"'
      substituteInPlace tools/helpers/instance.py \
        --replace-fail \
          'return f"/var/lib/miodroid{get_suffix()}"' \
          'return os.environ.get("MIODROID_WORK", f"/var/lib/miodroid{get_suffix()}")'
      substituteInPlace tools/config/__init__.py \
        --replace-fail \
          'defaults["images_path"] = defaults["work"] + "/images"' \
          'defaults["images_path"] = defaults["work"] + "/images"'
      sed -i 's|/waydroid{instance_suffix}|/miodroid{instance_suffix}|' \
        tools/config/__init__.py

      # cfg["waydroid"] section key in Python  →  cfg["miodroid"]
      find . -name "*.py" -exec sed -i \
        -e 's/cfg\["waydroid"\]/cfg["miodroid"]/g' \
        -e "s/cfg\['waydroid'\]/cfg['miodroid']/g" \
        {} +
      find data/configs -type f -exec sed -i \
        -e 's|/var/lib/waydroid|/var/lib/miodroid|g' \
        -e 's|/lxc/waydroid|/lxc/miodroid|g' \
        -e 's|waydroid\.seccomp|miodroid.seccomp|g' \
        -e 's|waydroid0|miodroid0|g' \
        -e 's|waydroid|miodroid|g' \
        {} +

      # D-Bus name (id.waydro → id.miodro)
      find . \( -name "*.conf" -o -name "*.service" -o -name "*.policy" -o -name "*.py" \) \
        -exec sed -i 's/id\.waydro\.Container/id.miodro.Container/g' {} +

      # systemd / D-Bus exec paths
      find . \( -name "*.service" -o -name "*.conf" \) \
        -exec sed -i \
          -e 's|/usr/bin/waydroid|/usr/bin/miodroid|g' \
          -e 's/waydroid-container\.service/miodroid-container.service/g' \
        {} +

      # Internal work-dir paths and filenames
      find . \( -name "*.py" -o -name "*.sh" -o -name "Makefile" \) \
        -exec sed -i \
          -e 's|/var/lib/waydroid|/var/lib/miodroid|g' \
          -e 's|/etc/waydroid-extra|/etc/miodroid-extra|g' \
          -e 's|/usr/share/waydroid-extra|/usr/share/miodroid-extra|g' \
          -e 's|/lxc/waydroid|/lxc/miodroid|g' \
          -e 's|+ "/waydroid"|+ "/miodroid"|g' \
          -e 's|/waydroid\.cfg|/miodroid.cfg|g' \
          -e 's|/waydroid\.log|/miodroid.log|g' \
          -e 's|waydroid_base\.prop|miodroid_base.prop|g' \
          -e 's|waydroid\.seccomp|miodroid.seccomp|g' \
          -e 's|"lxc-waydroid"|"lxc-miodroid"|g' \
          -e 's|"-n", "waydroid"|"-n", "miodroid"|g' \
          -e 's|waydroid0|miodroid0|g' \
          -e 's|waydroid_|miodroid_|g' \
          -e 's|"waydroid\.cfg"|"miodroid.cfg"|g' \
          -e 's|waydroid-bugreport|miodroid-bugreport|g' \
          -e 's|glob("waydroid\.|glob("miodroid.|g' \
          -e "s|glob('waydroid\\.|glob('miodroid.|g" \
        {} +

      # CLI/user-facing text in Python
      find . -name "*.py" -exec sed -i \
        -e 's/prog="waydroid"/prog="miodroid"/g' \
        -e 's/run "waydroid/run "miodroid/g' \
        -e 's/Waydroid is not initialized/Miodroid is not initialized/g' \
        -e 's/WayDroid container is/Miodroid container is/g' \
        -e "s/\"Run waydroid/\"Run miodroid/g" \
        -e 's/set_icon_name("waydroid")/set_icon_name("miodroid")/g' \
        -e 's/f"waydroid app /f"miodroid app /g' \
        -e 's/f"waydroid\.{/f"miodroid.{/g' \
        -e 's/f"waydroid\.{appInfo/f"miodroid.{appInfo/g' \
        {} +

      # Version string bump
      sed -i 's/version = "${version}"/version = "${version}+miodroid1"/' \
        tools/config/__init__.py

      # Config INI section header  [waydroid] → [miodroid]  (in load.py only)
      sed -i \
        -e 's/"waydroid" not in cfg/"miodroid" not in cfg/g' \
        -e 's/cfg\["waydroid"\] = {}/cfg["miodroid"] = {}/g' \
        tools/config/load.py

      # OTA servers use the upstream waydroid_<arch> path as a protocol
      # identifier; it is not a local name and must remain unchanged.
      substituteInPlace tools/actions/initializer.py \
        --replace-fail '"/miodroid_"' '"/waydroid_"'
      substituteInPlace tools/actions/container_manager.py \
        --replace-fail 'tools.config.defaults["lxc"] + "/waydroid/config"' \
        'tools.config.defaults["lxc"] + "/miodroid/config"'

      # Rename D-Bus files
      mv dbus/id.waydro.Container.conf    dbus/id.miodro.Container.conf
      mv dbus/id.waydro.Container.service dbus/id.miodro.Container.service
      [ -f dbus/id.waydro.Container.policy ] && \
        mv dbus/id.waydro.Container.policy dbus/id.miodro.Container.policy || true

      # Rename and update systemd service
      mv systemd/waydroid-container.service systemd/miodroid-container.service
      sed -i 's/Description=Waydroid Container/Description=Miodroid Container/' \
        systemd/miodroid-container.service

      # Rename Makefile: lib dir, binary symlink, icon, dbus files, apparmor, service
      sed -i \
        -e 's|lib/waydroid|lib/miodroid|g' \
        -e 's|WAYDROID_DIR|MIODROID_DIR|g' \
        -e 's|\$(INSTALL_BIN_DIR)/waydroid$|\$(INSTALL_BIN_DIR)/miodroid|' \
        -e 's|apps/waydroid\.png|apps/miodroid.png|g' \
        -e 's|id\.waydro\.Container|id.miodro.Container|g' \
        -e 's|waydroid-container\.service|miodroid-container.service|g' \
        -e 's|lxc-waydroid|lxc-miodroid|g' \
        Makefile

      # AppArmor profile rename
      mv data/configs/apparmor_profiles/lxc-waydroid \
         data/configs/apparmor_profiles/lxc-miodroid
      sed -i 's/lxc-waydroid/lxc-miodroid/g' \
        data/configs/apparmor_profiles/lxc-miodroid || true

      # The LXC configuration uses the rebranded seccomp filename.
      mv data/configs/waydroid.seccomp data/configs/miodroid.seccomp

      # ── Patch 0007: rootless mode ──────────────────────────────────────────
      #
      # Applied here rather than in the series above: the rootless changes
      # edit the rebranded code (miodroid paths, the multi-instance
      # helpers) and add tools/helpers/rootless.py.
      patch -p1 --batch < ${./patches/0007-rootless-mode.patch}

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

    preFixup = ''
      makeWrapperArgs+=("''${gappsWrapperArgs[@]}")

      patchShebangs --host $out/lib/miodroid/data/scripts
      wrapProgram $out/lib/miodroid/data/scripts/waydroid-net.sh \
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
