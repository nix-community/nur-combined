{ lib, stdenv, fetchFromGitHub, sassc, meson, ninja }:

stdenv.mkDerivation rec {
  pname = "adw-gtk3";
  version = "099f364c7b938ab1defd39e2cce0b47cfcb198d8";

  src = fetchFromGitHub {
    owner = "lassekongo83";
    repo = pname;
    rev = version;
    sha256 = "sha256-vXbdGuzbNMPKJ/5LmWvy8zSloJGXhGFxEBsSUaYT5Rw=";
  };

  nativeBuildInputs = [ meson ninja sassc ];

  meta = with lib; {
    description = "The theme from libadwaita ported to GTK-3";
    homepage = "https://github.com/lassekongo83/adw-gtk3";
    license = licenses.lgpl21;
    platforms = platforms.linux;
  };
}
