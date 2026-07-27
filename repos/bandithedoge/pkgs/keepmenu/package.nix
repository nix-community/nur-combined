{
  sources,

  lib,
  python3Packages,
}:
python3Packages.buildPythonApplication {
  inherit (sources.keepmenu) pname src;
  version = sources.keepmenu.date;

  format = "pyproject";

  propagatedBuildInputs = with python3Packages; [
    hatch-vcs
    hatchling
    pykeepass
    pynput
  ];

  doCheck = false;

  passthru._ignoreDupe = true;

  meta = {
    description = "Dmenu/Rofi frontend for Keepass databases";
    homepage = "https://github.com/firecat53/keepmenu";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    broken = true;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
