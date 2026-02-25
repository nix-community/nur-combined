{
  lib,
  stdenv,
  fetchurl,
  python3Packages,
  makeShellWrapper,
  callPackage,
  gtk3,
  gtk-layer-shell,
  cairo,
  gobject-introspection,
  libdbusmenu-gtk3,
  gdk-pixbuf,
  librsvg,
  gnome-bluetooth,
  cinnamon-desktop,
  extraPythonPackages ? [ ],
  extraBuildInputs ? [ ],
}:

let
  pygobject_3_50 = python3Packages.pygobject3.overrideAttrs (old: {
    version = "3.50.0";
    src = fetchurl {
      url = "mirror://gnome/sources/pygobject/3.50/pygobject-3.50.0.tar.xz";
      hash = "sha256-jYNudbWogdRX7hYiyuSjK826KKC6ViGTrbO7tHJHIhI=";
    };
  });
  fabric = callPackage ../fabric { };
  python = python3Packages.python.withPackages (
    ps:
    with ps;
    [
      click
      pycairo
      pygobject_3_50
      loguru
      psutil
      pygobject-stubs
      fabric
    ]
    ++ extraPythonPackages
  );
in
stdenv.mkDerivation {
  pname = "run-fabric";
  version = "1.0.0";

  nativeBuildInputs = [ makeShellWrapper ];

  buildInputs = [
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

  # We only execute the installPhase because run-fabric is just a Python wrapper,
  # and does not require source unpacking, compilation, or testing.
  # Nix's stdenv defines the following default build phases:
  #   unpackPhase       - unpack or download the source
  #   patchPhase        - apply patches
  #   configurePhase    - configure the build environment
  #   buildPhase        - compile the source code
  #   checkPhase        - run tests
  #   installPhase      - install files into $out
  #   fixupPhase        - fix rpaths, permissions, etc.
  #   installCheckPhase - optional post-install checks
  #   distPhase         - create distribution packages
  #   cleanPhase        - clean up the build directory
  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    makeShellWrapper ${python.interpreter} $out/bin/run-fabric \
      --set GI_TYPELIB_PATH "$GI_TYPELIB_PATH" \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE"
  '';

  meta = {
    mainProgram = "run-fabric";
    description = "Wrapper to run Fabric widgets";
    homepage = "https://github.com/Fabric-Development/fabric";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
}
