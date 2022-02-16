{ lib, fetchPypi, buildPythonApplication, setuptools_scm, installShellFiles
, pillow, convcolors }:

buildPythonApplication rec {
  pname = "extcolors";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "09sggji31ps2mm7klqvm9f7mwm8xgmkxwpbsq0vblmc5z5bi9s0l";
  };

  pythonImportsCheck = [ "extcolors" ];

  nativeBuildInputs = [ setuptools_scm installShellFiles ];

  propagatedBuildInputs = [ pillow convcolors ];

  meta = with lib; {
    homepage = "https://github.com/CairX/extract-colors-py";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
