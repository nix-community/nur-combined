# Disclaimer: Some Claude Opus 4.6 was used to write this
{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  # Build tools
  setuptools,
  makeWrapper,
  # Qt
  qt6,
  # OpenGL
  mesa,
  libglvnd,
  # Python dependencies
  napari,
  numpy,
  matplotlib,
  scipy,
  scikit-image,
  dotmap,
  opt-einsum,
  magicgui,
  lmfit,
  pyqt5,
  pyside6,
  qtpy,
  pillow,
  pyconify,
  rawpy,
  exiv2,
  lensfunpy,
  numba,
  cython,
  markdown,
  colour-science,
  pyfftw,
  openimageio,
}:

buildPythonPackage rec {
  pname = "spektrafilm";
  version = "0.3.4";
  pyproject = true;
  doCheck = false;
  doInstallCheck = false;
  dontCheckRuntimeDeps = true;

  src = fetchFromGitHub {
    owner = "andreavolpato";
    repo = "spektrafilm";
    rev = "28bf883e1672e884307edc75852549376e13644e";
    hash = "sha256-K9K51VwH63hAhWrdogxtlyaaFSCikHS7KcgIyTu207A=";
  };

  patches = [ ./illuminants-enum.patch ];

  build-system = [ setuptools ];

  dependencies = [
    napari
    numpy
    matplotlib
    scipy
    scikit-image
    dotmap
    opt-einsum
    magicgui
    lmfit
    pyqt5
    pyside6
    qtpy
    pillow
    pyconify
    rawpy
    exiv2
    lensfunpy
    numba
    cython
    markdown
    colour-science
    pyfftw
    openimageio
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  postFixup = ''
    wrapProgram $out/bin/spektrafilm \
      --unset PYTHONPATH \
      --set QT_API pyside6 \
      --set QT_PLUGIN_PATH "${qt6.qtbase}/${qt6.qtbase.qtPluginPrefix}:${qt6.qtwayland}/${qt6.qtbase.qtPluginPrefix}" \
      --set QT_QPA_PLATFORM wayland \
      --prefix LD_LIBRARY_PATH : "${mesa}/lib" \
      --prefix LD_LIBRARY_PATH : "${libglvnd}/lib" \
      --set LIBGL_DRIVERS_PATH "${mesa}/lib/dri" \
      --set __EGL_VENDOR_LIBRARY_DIRS "${mesa}/share/glvnd/egl_vendor.d"
  '';

  meta = with lib; {
    description = "Spektrafilm - film emulation tool";
    homepage = "https://github.com/andreavolpato/spektrafilm";
    mainProgram = "spektrafilm";
  };
}
