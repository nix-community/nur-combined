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

  meta = with pkgs.lib; {
    description = "Dmenu/Rofi frontend for Keepass databases";
    homepage = "https://github.com/firecat53/keepmenu";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
