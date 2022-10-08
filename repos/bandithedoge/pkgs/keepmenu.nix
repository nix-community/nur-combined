{
  pkgs,
  sources,
}:
pkgs.python310Packages.buildPythonApplication {
  inherit (sources.keepmenu) pname version src;

  doCheck = false;

  propagatedBuildInputs = with pkgs.python310Packages; [
    pynput
    pykeepass
  ];
}
