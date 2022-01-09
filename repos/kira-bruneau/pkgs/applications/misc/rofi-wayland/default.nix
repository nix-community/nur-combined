{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, bison
, check
, flex
, gdk-pixbuf
, librsvg
, libstartup_notification
, libxkbcommon
, pango
, wayland
, wayland-protocols
, xcb-util-cursor
, xcbutilwm
}:

stdenv.mkDerivation rec {
  pname = "rofi-wayland";
  version = "1.7.2";

  src = fetchFromGitHub {
    owner = "lbonn";
    repo = "rofi";
    rev = "${version}+wayland1";
    fetchSubmodules = true;
    sha256 = "sha256-INFYHOVjBNj8ks4UjKnxLW8mL7h1c8ySFPS/rUxOWwo=";
  };

  nativeBuildInputs = [
    ninja
    meson
    pkg-config
  ];

  buildInputs = [
    bison
    check
    flex
    gdk-pixbuf
    libstartup_notification
    libxkbcommon
    pango
    wayland
    wayland-protocols
    xcb-util-cursor
    xcbutilwm
  ];

  mesonFlags = [
    "-Dwayland=enabled"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Window switcher, run dialog and dmenu replacement (built for Wayland)";
    homepage = "https://github.com/lbonn/rofi";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.linux;
  };
}
