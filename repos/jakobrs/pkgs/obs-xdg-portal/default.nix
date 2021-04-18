{ stdenv, lib, fetchFromGitLab,
  meson, cmake, ninja, pkg-config,
  obs-studio, libX11, glib, pipewire, xdg-desktop-portal }:

stdenv.mkDerivation {
  pname = "obs-xdg-portal";
  version = "unstable-2021-01-06";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "feaneron";
    repo = "obs-xdg-portal";
    rev = "ee5241aed1a201d2dfa1af6be22762144bd61f0b";
    hash = "sha256:0qqwjs8p1l67zrx0i3sd11wg6y6bhs64zd8cjzd9nfsl50ivb0b4";
  };

  nativeBuildInputs = [ meson cmake ninja pkg-config ];

  buildInputs = [ obs-studio libX11 glib pipewire xdg-desktop-portal ];
}
