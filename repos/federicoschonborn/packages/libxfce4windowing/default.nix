{ lib, xfce }:

xfce.mkXfceDerivation {
  category = "xfce";
  pname = "libxfce4windowing";
  version = "4.19.2";
  sha256 = "sha256-mXxxyfwZB/AJFVVGFAAXLqC5p7pZAeqmhljQym55hyM=";

  meta =  {
    description = "Windowing concept abstraction library for X11 and Wayland";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
