# by-name/to/toshy/package.nix
#
# Builds the Toshy externally-managed Python runtime: a wrapped Python
# environment containing xwaykeyz (the keymapper) and all Toshy dependencies.
#
# Adapted from upstream nix/toshy-runtime.nix. The result is meant to be
# linked (by the home-manager module) at:
#     ${XDG_STATE_HOME:-~/.local/state}/toshy/runtime
# where Toshy's launcher scripts resolve it via toshy-runtime-env.sh.
#
# The Home Manager module links this package at the runtime path and also
# installs the user-level files (config tree, launchers, systemd units)
# from $out/share/toshy, so "setup_toshy.py install-user-files" is not required.
{
  lib,
  python3,
  fetchPypi,
  fetchFromGitHub,
  runCommand,
  makeWrapper,
  glib,
  atk,
  gtk3,
  gtk4,
  graphene,
  gdk-pixbuf,
  pango,
  libadwaita,
  libayatana-appindicator,
  harfbuzz,
  libdbusmenu-gtk3,
  gobject-introspection,
  gsettings-desktop-schemas,
  adwaita-icon-theme,
  procps,
  zenity,
  libnotify,
  xdg-utils,
  # "main" or "dev_beta" — selects which vendored keymapper copy inside
  # the Toshy source tree to build.
  keymapperBranch ? "main",
}:

let
  version = "26.08.0";

  src = fetchFromGitHub {
    owner = "RedBearAK";
    repo = "toshy";
    rev = "Toshy_v${version}";
    hash = "sha256-akmdwHhAMEDnk8Mh57UhM32ffgE3YSWdUPAecXG7R/0=";
  };

  # Version pins applied as an overlay so every package in the set resolves
  # to the pinned versions, including transitive dependents (i3ipc depends on
  # python-xlib; without the overlay the standard 0.33 shadows the pinned
  # 0.31 — which is exactly what tester logs showed upstream).
  pythonPinned = python3.override {
    packageOverrides = pyFinal: pyPrev: {

      # python-xlib pinned to 0.31 due to a BadRRModeError attribute bug in
      # newer releases. Built from scratch; its setup.py imports pkg_resources
      # (removed in setuptools 81+) only to assert setuptools >= 30, so it is
      # built with setuptools 80 via the setuptools-scm override, mirroring
      # nixpkgs' own python-xlib.
      python-xlib = pyFinal.buildPythonPackage rec {
        pname = "python-xlib";
        version = "0.31";
        pyproject = true;
        src = fetchPypi {
          inherit pname version;
          hash = "sha256-dNg6CB9TK8B/bXr81kFuw4QD1o9oubncnh8o+/LXmek=";
        };
        build-system = [
          (pyFinal.setuptools-scm.override { setuptools = pyFinal.setuptools_80; })
        ];
        dependencies = [ pyFinal.six ];
        doCheck = false;
        pythonImportsCheck = [ "Xlib" ];
      };

      # xkbcommon pinned below 1.1 (1.5 introduced breaking API changes;
      # pin advised by the python-xkbcommon maintainer).
      xkbcommon = pyPrev.xkbcommon.overridePythonAttrs (old: {
        version = "1.0.1";
        src = fetchPypi {
          pname = "xkbcommon";
          version = "1.0.1";
          hash = "sha256-npdJ1uy6UUFhZipGi6OGiatrbpYq9C4J+6Xuq8t3bJE=";
        };
        doCheck = false;
      });
    };
  };

  pyPkgs = pythonPinned.pkgs;

  kmSrcPath = "${src}/vendors/xwaykeyz-${keymapperBranch}";

  # Parse the vendored keymapper version from its version.py file.
  kmVersionLines = lib.splitString "\n" (builtins.readFile "${kmSrcPath}/src/xwaykeyz/version.py");
  kmVersionMatches = lib.concatMap (
    line:
    let
      m = builtins.match "__version__[[:space:]]*=[[:space:]]*['\"]([^'\"]+)['\"].*" line;
    in
    if m == null then [ ] else m
  ) kmVersionLines;
  kmVersion = if kmVersionMatches == [ ] then "unknown" else builtins.head kmVersionMatches;

  # ---- Packages not in nixpkgs ----

  # Not in nixpkgs. Pure Python; xwaykeyz uses it for the Hyprland backend.
  hyprpy = pyPkgs.buildPythonPackage rec {
    pname = "hyprpy";
    version = "0.1.10";
    pyproject = true;
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-OX8iOglHMFAwq0LT1cE4nhpP9BxgWFcgc3potqSNIAg=";
    };
    build-system = [ pyPkgs.setuptools ];
    dependencies = [ pyPkgs.pydantic ];
    doCheck = false;
    pythonImportsCheck = [ "hyprpy" ];
  };

  # ---- The keymapper, built from the vendored source tree ----

  xwaykeyz = pyPkgs.buildPythonPackage {
    pname = "xwaykeyz";
    version = kmVersion;
    pyproject = true;
    src = kmSrcPath;
    build-system = [ pyPkgs.hatchling ];
    dependencies =
      with pyPkgs;
      [
        anyascii
        appdirs
        dbus-python
        evdev
        i3ipc
        inotify-simple
        ordered-set
        pywayland
        python-xlib
      ]
      ++ [ hyprpy ];
    # nixpkgs ships newer versions than the compatible-release pins in the
    # keymapper's pyproject (dbus-python 1.4.x vs ~=1.3.2, inotify-simple
    # 2.x vs ~=1.3). Both are runtime-compatible for xwaykeyz's usage.
    # The strict python-xlib==0.31 pin is deliberately NOT relaxed.
    pythonRelaxDeps = [
      "dbus-python"
      "inotify-simple"
    ];
    doCheck = false;
    pythonImportsCheck = [ "xwaykeyz" ];
  };

  # ---- Full environment: Toshy app deps + the keymapper ----

  pythonEnv = pythonPinned.withPackages (
    ps:
    with ps;
    [
      dbus-python
      lockfile
      pillow
      psutil
      pygobject3
      sv-ttk
      systemd-python
      tkinter
      watchdog
      xkbcommon
    ]
    ++ [ xwaykeyz ]
  );

  # ---- GI typelibs and schemas for the tray / GTK4 preferences app ----

  giPackages = [
    glib
    atk
    gtk3
    gtk4
    graphene
    gdk-pixbuf
    pango
    harfbuzz # Pango's typelib hard-requires HarfBuzz-0.0
    libdbusmenu-gtk3 # AyatanaAppIndicator3 chain requires Dbusmenu
    libadwaita
    libayatana-appindicator
    gobject-introspection
  ];

  # makeSearchPathOutput targets the "out" output explicitly: several of
  # these packages (pango notably) list "bin" as their first/default output,
  # which contains no typelibs, so plain makeSearchPath would silently omit
  # them (symptom: "Typelib file for namespace 'PangoCairo' ... not found").
  giTypelibPath = lib.makeSearchPathOutput "out" "lib/girepository-1.0" giPackages;

  xdgDataDirs = lib.concatStringsSep ":" [
    "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"
    "${gtk4}/share/gsettings-schemas/${gtk4.name}"
    "${gtk3}/share/gsettings-schemas/${gtk3.name}"
    "${adwaita-icon-theme}/share"
  ];

in
runCommand "toshy-${keymapperBranch}-${version}"
  {
    nativeBuildInputs = [ makeWrapper ];
    inherit src;
    passthru = {
      inherit src pythonEnv xwaykeyz;
    };
    meta = {
      description = "Mac-style keyboard remapping for Linux (Toshy runtime environment)";
      longDescription = ''
        Toshy is a keymapper config that makes Linux keyboard shortcuts work
        like macOS ("a Tosh"). This package provides the externally-managed
        Python runtime environment containing xwaykeyz (the keymapper) and
        all Toshy dependencies, plus the user-level file tree installed by
        the home-manager module (launchers, systemd units, default config).
      '';
      homepage = "https://github.com/RedBearAK/toshy";
      license = lib.licenses.gpl3Plus;
      platforms = lib.platforms.linux;
      maintainers = [ ];
    };
  }
  ''
    mkdir -p $out/bin $out/share/toshy
    for exe_path in ${pythonEnv}/bin/*; do
        exe_name=$(basename "$exe_path")
        makeWrapper "$exe_path" "$out/bin/$exe_name" \
            --prefix GI_TYPELIB_PATH : "${giTypelibPath}" \
            --prefix XDG_DATA_DIRS : "${xdgDataDirs}" \
            --prefix PATH : "${
              lib.makeBinPath [
                procps
                glib
                zenity
                libnotify
                xdg-utils
              ]
            }"
    done

    # Same tree "setup_toshy.py install-user-files" copies into ~/.config/toshy
    # (minus ignored repo metadata / vendored keymapper / tests).
    for d in \
        assets \
        cinnamon-extension \
        cosmic-dbus-service \
        default-toshy-config \
        desktop \
        kwin-dbus-service \
        kwin-script \
        scripts \
        systemd-user-service-units \
        toshy_common \
        toshy_gui \
        wlroots-dbus-service \
        wlroots-dev
    do
        cp -r "$src/$d" "$out/share/toshy/"
    done
    cp "$src/toshy_layout_selector.py" "$src/toshy_tray.py" "$src/setup_toshy.py" "$out/share/toshy/"
    cp "$src/default-toshy-config/toshy_config.py" "$out/share/toshy/toshy_config.py.default"
    cp "$src/default-toshy-config/toshy_config_barebones.py" "$out/share/toshy/toshy_config_barebones.py.default"
    chmod -R u+w "$out/share/toshy"
  ''
