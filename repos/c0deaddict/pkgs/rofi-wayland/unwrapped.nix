{ stdenv, lib, fetchFromGitHub, autoreconfHook, pkgconfig, libxkbcommon, pango
, which, git, wayland-protocols, cairo, libxcb, xcbutil, xcbutilwm, xcbutilxrm
, libstartup_notification, bison, flex, librsvg, check, meson, ninja, wayland }:

stdenv.mkDerivation rec {
  pname = "rofi-wayland-unwrapped";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "lbonn";
    repo = "rofi";
    rev = "${version}-wayland";
    sha256 = "1n1hkv14qfcqfc15h4qswjxiagd9xps9n0zcrwmkrkmd6bi0w3ra";
    fetchSubmodules = true;
  };

  preConfigure = ''
    patchShebangs "script"
    # root not present in build /etc/passwd
    sed -i 's/~root/~nobody/g' test/helper-expand.c
  '';

  nativeBuildInputs = [ meson ninja pkgconfig ];
  buildInputs = [
    libxkbcommon
    pango
    cairo
    git
    bison
    flex
    librsvg
    check
    libstartup_notification
    libxcb
    xcbutil
    xcbutilwm
    xcbutilxrm
    which
    wayland-protocols
    wayland
  ];

  doCheck = false;

  meta = with lib; {
    description = "Window switcher, run dialog and dmenu replacement";
    homepage = "https://github.com/davatorium/rofi";
    license = licenses.mit;
    maintainers = with maintainers; [ mbakke ];
    platforms = with platforms; linux;
  };
}
