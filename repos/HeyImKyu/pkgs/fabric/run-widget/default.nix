{
  lib,
  python3,
  stdenv,
  fabric,
  pkgs,
  extraPythonPackages ? [],
  extraBuildInputs ? [],
  ...
}:

let
  python = python3.withPackages (
    ps: with ps;
    [
      click
      pycairo
      pygobject3
      loguru
      psutil
      pygobject-stubs
      fabric
    ]
    ++ extraPythonPackages
  );
in
stdenv.mkDerivation {
  pname = "run-widget";
  version = "0.0.3";

  propagatedBuildInputs = with pkgs; [
    gtk3
    gtk-layer-shell
    cairo
    gobject-introspection
    libdbusmenu-gtk3
    gdk-pixbuf
    librsvg
    gnome-bluetooth
    cinnamon-desktop
  ]
  ++ extraBuildInputs;

  phases = ["installPhase"];

  installPhase = ''
    mkdir -p $out/bin
    cat > $out/bin/run-widget << EOF
    #!/bin/sh
    GI_TYPELIB_PATH=$GI_TYPELIB_PATH \
    GDK_PIXBUF_MODULE_FILE="$GDK_PIXBUF_MODULE_FILE" \
    ${python.interpreter} "\$@"
    EOF
    chmod +x $out/bin/run-widget
  '';

  meta = {
    mainProgram = "run-widget";
    description = "Wrapper to run Fabric widgets";
    homepage = "https://github.com/Fabric-Development/fabric";
    license = lib.licenses.agpl3Plus;
    maintainers = [
      {
        email = "heyimkyu@mailbox.org";
        github = "HeyImKyu";
        githubId = 43815343;
        name = "Kyu";
      }
    ];
  };
}
