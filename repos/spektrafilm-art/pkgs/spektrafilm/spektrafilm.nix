# Disclaimer: Some Claude Opus 4.6 was used to write this
{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  # Build tools
  setuptools,
  makeWrapper,
  # Qt
  qt5,
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
  rawpy,
  numba,
  cython,
  colour-science,
  pyfftw,
  openimageio,
}:

buildPythonPackage rec {
  pname = "spektrafilm";
  version = "0.1.0-dev";
  pyproject = true;
  doCheck = false;
  doInstallCheck = false;
  dontCheckRuntimeDeps = true;

  src = fetchFromGitHub {
    owner = "andreavolpato";
    repo = "spektrafilm";
    rev = "3d3b7daae2d41df325dae04eb108beb3f0e19423";
    hash = "sha256-5mq59/bzqVInVAF+bsdMNJJp+Enx/GYTxUpexXIHjAg=";
  };

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
    rawpy
    numba
    cython
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
      --set QT_API pyqt5 \
      --set QT_PLUGIN_PATH "${qt5.qtbase.bin}/${qt5.qtbase.qtPluginPrefix}:${qt5.qtwayland.bin}/${qt5.qtbase.qtPluginPrefix}" \
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
