{
  sources,
  python3Packages,
  lib,
}:

python3Packages.buildPythonPackage {
  inherit (sources.ly2video) pname version src;

  pyproject = true;
  build-system = with python3Packages; [ setuptools ];

  propagatedBuildInputs = with python3Packages; [
    setuptools
    pillow
    pexpect
    mido
  ];

  meta = with lib; {
    homepage = "https://github.com/aspiers/ly2video";
    description = "Generating videos from LilyPond projects";
    maintainers = with maintainers; [ yinfeng ];
    license = licenses.gpl3;
  };
}
