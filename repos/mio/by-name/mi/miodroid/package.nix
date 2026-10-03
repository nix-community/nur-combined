{
  lib,
  fetchFromGitHub,
  python3Packages,
  dnsmasq,
  gawk,
  getent,
  gobject-introspection,
  gtk3,
  kmod,
  lxc,
  iproute2,
  iptables,
  nftables,
  util-linux,
  wrapGAppsHook3,
  wl-clipboard,
  runtimeShell,
  nix-update-script,
  withNftables ? false,
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
#
# To pull changes from upstream Lepton (https://github.com/casualsnek/waydroid-lepton
# or similar), add further patches in the patches/ directory and list them below.

python3Packages.buildPythonApplication rec {
  pname = "miodroid";
  version = "1.6.3";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "waydroid";
    repo = "waydroid";
    tag = version;
    hash = "sha256-1YYNSqIW+0vkCRZ+vemqu0CXhU6aOGvpMzdswvlAc84=";
  };

  # ---------------------------------------------------------------------------
  # Patch series
  # ---------------------------------------------------------------------------
  # Renaming is applied via sed across all source files. The patches/ directory
  # has human-readable git-style commit descriptions for each change set so they
  # can be ported to a real upstream fork later.
  # ---------------------------------------------------------------------------

  postPatch = ''
    # ── Patches 0001-0003: global rebrand waydroid → miodroid ──────────────
    #
    # Use sed across the whole tree to avoid per-file failures.
    # Order matters: rename more-specific strings first.

    # cfg["waydroid"] section key in Python  →  cfg["miodroid"]
    find . -name "*.py" -exec sed -i \
      -e 's/cfg\["waydroid"\]/cfg["miodroid"]/g' \
      -e "s/cfg\['waydroid'\]/cfg['miodroid']/g" \
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
        -e 's|/waydroid\.cfg|/miodroid.cfg|g' \
        -e 's|/waydroid\.log|/miodroid.log|g' \
        -e 's|waydroid_base\.prop|miodroid_base.prop|g' \
        -e 's|waydroid\.seccomp|miodroid.seccomp|g' \
        -e 's|"lxc-waydroid"|"lxc-miodroid"|g' \
        -e 's|"-n", "waydroid"|"-n", "miodroid"|g' \
        -e 's|waydroid0|miodroid0|g' \
        -e 's|waydroid_|miodroid_|g' \
      {} +

    # CLI/user-facing text in Python
    find . -name "*.py" -exec sed -i \
      -e 's/prog="waydroid"/prog="miodroid"/g' \
      -e 's/run "waydroid/run "miodroid/g' \
      -e 's/Waydroid is not initialized/Miodroid is not initialized/g' \
      -e 's/WayDroid container is/Miodroid container is/g' \
      -e "s/\"Run waydroid/\"Run miodroid/g" \
      -e 's/set_icon_name("waydroid")/set_icon_name("miodroid")/g' \
      {} +

    # Version string bump
    sed -i 's/version = "${version}"/version = "${version}+miodroid1"/' \
      tools/config/__init__.py

    # Config INI section header  [waydroid] → [miodroid]  (in load.py only)
    sed -i \
      -e 's/"waydroid" not in cfg/"miodroid" not in cfg/g' \
      -e 's/cfg\["waydroid"\] = {}/cfg["miodroid"] = {}/g' \
      tools/config/load.py

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

  # The Makefile is already patched to install as 'miodroid', so postInstall
  # just renames any residual waydro D-Bus installed files (polkit, etc).
  postInstall = ''
    # Rename any D-Bus / polkit installed files with old name (best-effort)
    for f in "$out"/share/dbus-1/system.d/id.waydro.Container.conf \
              "$out"/share/dbus-1/system-services/id.waydro.Container.service \
              "$out"/share/polkit-1/actions/id.waydro.Container.policy; do
      [ -e "$f" ] && mv "$f" "$(dirname "$f")/$(basename "$f" | sed 's/waydro/miodro/g')" || true
    done
  '';

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
          util-linux
          wl-clipboard
        ]
      )
    }"

    substituteInPlace $out/lib/miodroid/tools/helpers/run.py \
                      $out/lib/miodroid/tools/helpers/lxc.py \
      --replace-fail '"sh"' '"${runtimeShell}"'
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Miodroid: a rebranded Waydroid fork for parallel installation (container-based Android on Linux)";
    mainProgram = "miodroid";
    homepage = "https://github.com/waydroid/waydroid";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
