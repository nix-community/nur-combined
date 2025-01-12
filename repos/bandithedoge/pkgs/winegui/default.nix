{
  pkgs,
  sources,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.winegui) pname src;
  version = sources.winegui.date;

  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
  ];

  buildInputs = with pkgs; [
    gtkmm3
  ];

  meta = with pkgs.lib; {
    description = "A user-friendly WINE manager";
    homepage = "https://gitlab.melroy.org/melroy/winegui";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
  };
}
