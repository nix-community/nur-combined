{
  sources,
  python3Packages,
  lib,
}:

python3Packages.buildPythonPackage {
  inherit (sources.ly2video) pname version src;
  propagatedBuildInputs = with python3Packages; [
    setuptools
    pillow
    pexpect
    mido
  ];
  meta = with lib; {
    description = "Generating videos from LilyPond projects";
    maintainers = with maintainers; [ yinfeng ];
    license = licenses.gpl3;
  };
}
