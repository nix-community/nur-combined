{
  lib,
  python3Packages,
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
  callPackage,
}:
let
  current = lib.trivial.importJSON ./version.json;

  pygobject_3_50 = python3Packages.pygobject3.overrideAttrs (old: {
    version = "3.50.0";
    src = fetchurl {
      url = "mirror://gnome/sources/pygobject/3.50/pygobject-3.50.0.tar.xz";
      hash = current.pygobject_hash;
    };
  });
in
python3Packages.buildPythonPackage {
  pname = "fabric";
  version = current.version;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "fabric";
    rev = current.rev;
    hash = current.hash;
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

  dependencies = with python3Packages; [
    setuptools
    click
    pycairo
    pygobject_3_50
    pygobject-stubs
    loguru
    psutil
  ];

  passthru.updateScript = callPackage ../../utils/update.nix {
    pname = "fabric";
    versionFile = "pkgs/fabric/version.json";
    fetchMetaCommand = "${(callPackage ../../utils/fetcher.nix { }).githubGit {
      owner = "Fabric-Development";
      repo = "fabric";
    }}";
  };

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
