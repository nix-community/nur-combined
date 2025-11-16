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
  version = "0.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "fabric";
    rev = "0f3d317b047799191ff04a32352a63084eac11d9";
    hash = "sha256-ELXYed743Xnad8hOMmN5RI0S8w0rltcZbylQjjFiv6s=";
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

  passthru.updateScript = ./update.sh;

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
