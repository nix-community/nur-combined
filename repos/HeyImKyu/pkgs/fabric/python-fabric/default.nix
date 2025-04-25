{
  lib,
  python312Packages,
  pkgs,
  fetchFromGitHub,
  ...
}:

python312Packages.buildPythonPackage {
  pname = "python-fabric";
  version = "0.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "fabric";
    rev = "1831ced4d9bb9f4be3893be55a8d502b47bff29e";
    hash = "sha256-1dZTqsWPaHyWjZkX4MaJdwUAQoMXwr8hhHymxQIwFrY=";
  };

  buildInputs = with pkgs; [
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
