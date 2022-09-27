{ lib, fetchPypi, buildPythonApplication, setuptools-scm, installShellFiles
, pillow, convcolors }:

buildPythonApplication rec {
  pname = "extcolors";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "09sggji31ps2mm7klqvm9f7mwm8xgmkxwpbsq0vblmc5z5bi9s0l";
  };

  pythonImportsCheck = [ "extcolors" ];

  nativeBuildInputs = [ setuptools-scm installShellFiles ];

  propagatedBuildInputs = [ pillow convcolors ];

  meta = with lib; {
    description =
      "Extract colors from an image. Colors are grouped based on visual similarities using the CIE76 formula";
    homepage = "https://github.com/CairX/extract-colors-py";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
