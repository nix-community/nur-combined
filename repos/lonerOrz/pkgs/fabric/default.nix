{
  lib,
  python312Packages,
  fetchFromGitHub,
  gtk3,
  gtk-layer-shell,
  cairo,
  gobject-introspection,
  libdbusmenu-gtk3,
  gdk-pixbuf,
  cinnamon-desktop,
  gnome-bluetooth,
}:

python312Packages.buildPythonPackage rec {
  pname = "fabric";
  version = "0.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "fabric";
    tag = "v${version}";
    hash = "sha256-8HrzieeOj9dmRNXXV1AA6jV7COVYPnD7dK9npPxtER4=";
  };

  postPatch = ''
    sed -i 's/pygobject==3.50.0/pygobject>=3.50.0/' setup.py
  '';

  buildInputs = [
    gtk3
    gtk-layer-shell
    cairo
    gobject-introspection
    libdbusmenu-gtk3
    gdk-pixbuf
    cinnamon-desktop
    gnome-bluetooth
  ];

  dependencies = with python312Packages; [
    setuptools
    click
    pycairo
    pygobject3
    pygobject-stubs
    loguru
    psutil
  ];

  meta = {
    description = "Next-gen framework for building desktop widgets using Python";
    longDescription = ''
      This is the python package for fabric.
      In this context it is only used for inclusion in the run-widget flake.
    '';
    homepage = "https://github.com/Fabric-Development/fabric";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
}
