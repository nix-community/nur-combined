{ stdenv, lib, fetchFromGitHub, pkgconfig, gtk3, vte_290, systemd, intltool }:

stdenv.mkDerivation rec {
  pname = "gtkterm";
  version = "unstable-2018-12-22";

  src = fetchFromGitHub {
    owner = "zdavkeos";
    repo = pname;
    rev = "c41149e6f8df02dcbe69e94e382cef49e59df911";
    sha256 = "1qzizgj20pmzq30jdffpxmvh2w395yrjnh284j7wmsbzc1h3fbph";
  };

  nativeBuildInputs = [ pkgconfig intltool ];
  buildInputs = [ gtk3 systemd vte_290 ];

  meta = with lib; {
    description = "GTK+ serial port terminal";
    homepage = https://github.com/zdavkeos/gtkterm;
    license = licenses.gpl3;
    maintainers = [ maintainers.johnazoidberg ];
    platforms = platforms.linux;
  };
}
