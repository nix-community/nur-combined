{
  pkgs,
  sources,
  ...
}:
pkgs.python3Packages.buildPythonApplication {
  inherit (sources.keepmenu) pname src;
  version = sources.keepmenu.date;

  format = "pyproject";

  propagatedBuildInputs = with pkgs.python3Packages; [
    hatch-vcs
    hatchling
    pykeepass
    pynput
  ];

  doCheck = false;

  meta = with pkgs.lib; {
    description = "Dmenu/Rofi frontend for Keepass databases";
    homepage = "https://github.com/firecat53/keepmenu";
    license = licenses.gpl3;
    platforms = platforms.linux;
    broken = true;
  };
}
