{ lib
, sources
, python3Packages
, onepush
, genshinhelper2
, ...
} @ args:

with python3Packages;

let
  setupPy = ./setup.py;
in
buildPythonApplication rec {
  inherit (sources.genshin-checkin-helper) pname version src;

  preConfigure = ''
    cp ${setupPy} setup.py
  '';

  propagatedBuildInputs = [ schedule onepush genshinhelper2 ];
  doCheck = false;

  meta = with lib; {
    description = "More than check-in for Genshin Impact.";
    homepage = "https://gitlab.com/y1ndan/genshin-checkin-helper";
    license = with licenses; [ gpl3Only ];
  };
}
