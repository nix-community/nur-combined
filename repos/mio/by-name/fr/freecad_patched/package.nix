{
  lib,
  stdenv,
  desktopToDarwinBundle,
  fetchpatch,
  freecad,
  graphviz,
  gsettings-desktop-schemas,
  gtk3,
  libredwg,
  python3Packages,
  qt6,
  which,
}:

# nixpkgs marks FreeCAD as Linux-only and unconditionally adds Qt Wayland. The
# upstream build supports macOS, but installs the GUI and command-line
# executables under $out/MacOS rather than $out/bin.
if !stdenv.hostPlatform.isDarwin then
  freecad
else
  let
    pythonDeps = with python3Packages; [
      boost
      gitpython
      matplotlib
      opencamlib
      pivy
      ply
      pybind11
      pycollada
      pyside6
      python
      pyyaml
      scipy
      shiboken6
      vtk
      networkx
    ];
  in
  freecad.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (fetchpatch {
        name = "freecad-techdraw-std-abs-libcxx.patch";
        url = "https://github.com/FreeCAD/FreeCAD/commit/9e5555fe3fd762474a531da72a3aa1a3cdb1b6c4.patch";
        hash = "sha256-l7MTe8yo3u3A2SS0Ndm952pUtQLYMwNgS55Yr54y7dI=";
      })
      ./libcxx-std-less.patch
    ];

    # FreeCAD's headers and the compatibility patch use CRLF line endings.
    patchFlags = [
      "-p1"
      "--binary"
    ];

    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ desktopToDarwinBundle ];

    # Qt Wayland is Linux-only. ifcopenshell is optional and currently marked
    # broken on Darwin, so leave that BIM import extra out of this build.
    buildInputs = builtins.filter (
      input:
      !(builtins.elem (input.name or "") [
        qt6.qtwayland.name
        python3Packages.ifcopenshell.name
      ])
    ) (old.buildInputs or [ ]);

    qtWrapperArgs = [
      "--set"
      "COIN_GL_NO_CURRENT_CONTEXT_CHECK"
      "1"

      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath [
        graphviz
        libredwg
        which
      ])

      "--prefix"
      "PYTHONPATH"
      ":"
      (python3Packages.makePythonPath pythonDeps)

      "--prefix"
      "XDG_DATA_DIRS"
      ":"
      "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}"
    ];

    postInstall = (old.postInstall or "") + ''
      mkdir -p $out/bin $out/share/applications \
        $out/share/icons/hicolor/scalable/apps

      ln -s ../MacOS/FreeCAD $out/bin/FreeCAD
      ln -s ../MacOS/FreeCADCmd $out/bin/FreeCADCmd

      # FreeCAD only installs these freedesktop files on non-Darwin platforms.
      install -Dm644 ${old.src}/src/XDGData/org.freecad.FreeCAD.desktop \
        $out/share/applications/org.freecad.FreeCAD.desktop
      install -Dm644 ${old.src}/src/Gui/Icons/freecad-icon-16.png \
        $out/share/icons/hicolor/16x16/apps/org.freecad.FreeCAD.png
      install -Dm644 ${old.src}/src/Gui/Icons/freecad-icon-32.png \
        $out/share/icons/hicolor/32x32/apps/org.freecad.FreeCAD.png
      install -Dm644 ${old.src}/src/Gui/Icons/freecad-icon-48.png \
        $out/share/icons/hicolor/48x48/apps/org.freecad.FreeCAD.png
      install -Dm644 ${old.src}/src/Gui/Icons/freecad-icon-64.png \
        $out/share/icons/hicolor/64x64/apps/org.freecad.FreeCAD.png
      install -Dm644 ${old.src}/src/Gui/Icons/freecad.svg \
        $out/share/icons/hicolor/scalable/apps/org.freecad.FreeCAD.svg
    '';

    # The upstream postFixup adds lowercase aliases that collide with the
    # uppercase executables on Darwin's case-insensitive filesystem.
    postFixup = ''
      mv $out/share/doc $out
      ln -s $out/doc $out/share/doc

      cp ${old.src}/src/MacAppBundle/FreeCAD.app/Contents/Resources/freecad.icns \
        $out/Applications/FreeCAD.app/Contents/Resources/org.freecad.FreeCAD.icns
    '';

    meta = (old.meta or { }) // {
      platforms = lib.platforms.darwin;
    };
  })
