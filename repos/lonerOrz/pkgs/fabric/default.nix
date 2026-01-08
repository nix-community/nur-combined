{
  lib,
  python312Packages,
  fetchFromGitHub,
  fetchurl,
  gtk3,
  gtk-layer-shell,
  cairo,
  gobject-introspection,
  libdbusmenu-gtk3,
  gdk-pixbuf,
  cinnamon-desktop,
  gnome-bluetooth,
}:
let
  pygobject_hash = "sha256-jYNudbWogdRX7hYiyuSjK826KKC6ViGTrbO7tHJHIhI=";
  src_hash = "sha256-JkScB31Iq9A3mB4dHTskMTir31pm2AkcpTSU8PIG+qs=";

  pygobject_3_50 = python312Packages.pygobject3.overrideAttrs (old: {
    version = "3.50.0";
    src = fetchurl {
      url = "mirror://gnome/sources/pygobject/3.50/pygobject-3.50.0.tar.xz";
      hash = "${pygobject_hash}";
    };
  });
in
python312Packages.buildPythonPackage {
  pname = "fabric";
  version = "0.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "fabric";
    rev = "7809cc831c701531ea1461b5f0da11c13d78612e";
    hash = "${src_hash}";
  };

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
    pygobject_3_50
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
