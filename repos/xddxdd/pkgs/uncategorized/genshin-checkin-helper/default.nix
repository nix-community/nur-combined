{
  lib,
  sources,
  python3Packages,
  onepush,
  genshinhelper2,
}:
with python3Packages;
let
  setupPy = ./setup.py;
in
buildPythonApplication rec {
  inherit (sources.genshin-checkin-helper) pname version src;

  preConfigure = ''
    cp ${setupPy} setup.py
  '';

  propagatedBuildInputs = [
    schedule
    onepush
    genshinhelper2
  ];
  doCheck = false;

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "More than check-in for Genshin Impact";
    homepage = "https://gitlab.com/y1ndan/genshin-checkin-helper";
    license = with lib.licenses; [ gpl3Only ];
  };
}
