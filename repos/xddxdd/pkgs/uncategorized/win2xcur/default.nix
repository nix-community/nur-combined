{
  lib,
  sources,
  python3Packages,
  ...
}:
with python3Packages;
buildPythonPackage rec {
  inherit (sources.win2xcur) pname version src;

  propagatedBuildInputs = [
    numpy
    wand
  ];

  doCheck = false;

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "win2xcur is a tool that converts cursors from Windows format (*.cur, *.ani) to Xcursor format. It also contains x2wincur which does the opposite.";
    homepage = "https://github.com/quantum5/win2xcur";
    license = with licenses; [ gpl3Only ];
  };
}
