{
  pkgs,
  sources,
  ...
}: let
  qt5' = pkgs.runCommand "moc-qt5" {} ''
    mkdir -p $out/bin
    ln -s ${pkgs.qt5.qtbase.dev}/bin/moc $out/bin/moc-qt5
    ln -s ${pkgs.qt5.qtbase.dev}/bin/qmake $out/bin/qmake-qt5
    ln -s ${pkgs.qt5.qtbase.dev}/bin/uic $out/bin/uic-qt5
  '';
in
  pkgs.stdenv.mkDerivation {
    inherit (sources.radium) pname version src;

    patches = [./ignore-qt-path-mismatch.patch];

    nativeBuildInputs = with pkgs; [
      guile
      makeWrapper
      pkg-config
      which
    ];

    buildInputs = with pkgs; [
      qt5.full
      bintools-unwrapped
    ];

    postPatch = ''
      patchShebangs *.sh
      substituteInPlace Makefile.Qt --replace-fail "/usr/bin/env bash" ${pkgs.stdenv.shell}
      substituteInPlace bin/packages/build_python27.sh \
        --replace-fail clang++ "$CXX" \
        --replace-fail clang "$CC"
    '';

    buildPhase = ''
      echo $PKG_CONFIG_PATH
      cd bin/packages
      patchShebangs build_python27.sh
      source build_python27.sh
      build_python27
      cd ..
      patchShebangs python27_install/bin/python2.7
      wrapProgram python27_install/bin/python --prefix LD_LIBRARY_PATH : $(realpath python27_install/lib)
      ls -la python27_install/bin
      cd ../..

      make packages
      ./build_linux.sh
    '';

    installPhase = ''
      # ./install.sh
    '';

    dontWrapQtApps = true;

    BUILDTYPE = "RELEASE";
    RADIUM_QT_VERSION = 5;
    MOC = pkgs.qt5.qtbase.dev + "/bin/moc";
    UIC = pkgs.qt5.qtbase.dev + "/bin/uic";
    # RADIUM_QTDIR = pkgs.qt5.qtbase;
    RADIUM_USE_CLANG =
      if pkgs.stdenv.cc.isClang
      then 1
      else 0;
    # QT_PKG_CONFIGURATION_PATH = pkgs.lib.makeSearchPath "lib/pkgconfig" [pkgs.qt5.qtbase.dev];

    NIX_CFLAGS_COMPILE = map (x: "-I${x}/include") (with pkgs; [
      bintools-unwrapped.dev
    ]);

    NIX_LDFLAGS = map (x: "-L${x}/lib") (with pkgs; [
      bintools-unwrapped.lib
    ]);
  }
