{
  lib,
  fetchPypi,
  buildPythonApplication,
  setuptools-scm,
  installShellFiles,
  pillow,
  convcolors,
}:

buildPythonApplication rec {
  pname = "extcolors";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-FOgUV/mFVbo2wHpd3md9HVVej0t1YzpPrULfMKJ8Tyc=";
  };

  pythonImportsCheck = [ "extcolors" ];

  nativeBuildInputs = [
    setuptools-scm
    installShellFiles
  ];

  propagatedBuildInputs = [
    pillow
    convcolors
  ];

  meta = {
    description = "Extract colors from an image. Colors are grouped based on visual similarities using the CIE76 formula";
    homepage = "https://github.com/CairX/extract-colors-py";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
