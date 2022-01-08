{ lib, buildPythonApplication, fetchPypi, i3ipc, importlib-metadata }:

buildPythonApplication rec {
  pname = "swayblur";
  version = "1.1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "OS2eS3p0ig6dDO6/deOjXdXUOCRdHs4YuOwiaCc1qfs=";
  };

  propagatedBuildInputs = [ i3ipc importlib-metadata ];
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/willpower3309/swayblur";
    description = "Script for sway to blur the wallpaper upon clients being present";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
