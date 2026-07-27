{ stdenv, lib, fetchFromGitHub
, pkgconfig, meson, ninja, scdoc
, wayland, wayland-protocols, cairo
}:

stdenv.mkDerivation rec {
  pname = "wlclock";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Leon-Plickat";
    repo = "wlclock";
    rev = "v${version}";
    hash = "sha256-WayM1cLuwGMBd6QY+ywrKIYswJMQ4ZC8f15RbVTFk50=";
  };

  nativeBuildInputs = [ pkgconfig meson ninja ];

  buildInputs = [ scdoc wayland wayland-protocols cairo ];

  meta = with lib; {
    description = "A digital analog clock for Wayland desktops.";
    homepage = "https://github.com/Leon-Plickat/wlclock";
    license = licenses.gpl3;
    platform = platforms.linux;
    maintainer = [ maintainers.berbiche ];
  };
}
