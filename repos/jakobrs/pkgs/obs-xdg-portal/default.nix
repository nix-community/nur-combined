{ stdenv, lib, fetchFromGitLab,
  meson, cmake, ninja, pkg-config,
  obs-studio, libX11, glib, pipewire, xdg-desktop-portal }:

stdenv.mkDerivation {
  pname = "obs-xdg-portal-unstable";
  version = "2020-12-28";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "feaneron";
    repo = "obs-xdg-portal";
    rev = "8dd8fa3a69762daec98dcaedcd4efa57f2e3efb7";
    hash = "sha256:1bryvpqjwsrq3vk4igzfk10qq5zl8r4m172narxsr6yp7qp2kzza";
  };

  nativeBuildInputs = [ meson cmake ninja pkg-config ];

  buildInputs = [ obs-studio libX11 glib pipewire xdg-desktop-portal ];
}
