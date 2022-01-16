{ lib, buildPythonApplication, fetchPypi, i3ipc, importlib-metadata }:

buildPythonApplication rec {
  pname = "swayblur";
  version = "1.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "b6yj6GNqeynCJkp6yy/IN2LzQ0etSDGC1oK+s+Xav/g=";
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
