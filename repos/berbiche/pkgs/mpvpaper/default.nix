{ stdenv, fetchFromGitHub
, pkgconfig, meson, ninja, cmake
, wayland, wayland-protocols
, cairo, mpv, wlroots
}:

stdenv.mkDerivation rec {
  pname = "mpvpaper";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "GhostNaN";
    repo = "mpvpaper";
    rev = version;
    hash = "sha256-ZIV8pjRhGN5UUTHuqvYnD6SYyT9KfIkLROaHWVDLSls=";
  };

  nativeBuildInputs = [ pkgconfig meson ninja cmake ];

  buildInputs = [ wayland wayland-protocols mpv wlroots cairo ];

  meta = with stdenv.lib; {
    description = ''
      A wallpaper program for wlroots based Wayland compositors that
      allows you to play videos with mpv as your wallpaper
    '';
    homepage = "https://github.com/GhostNaN/mpvpaper";
    license = licenses.gpl3;
    platform = platforms.linux;
    maintainer = [ maintainers.berbiche ];
  };
}
