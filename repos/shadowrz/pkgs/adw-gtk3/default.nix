{ lib, stdenv, fetchFromGitHub, sassc, meson, ninja }:

stdenv.mkDerivation rec {
  pname = "adw-gtk3";
  version = "be9441ef8f1164aa0f9593ba3263711bea5c6a4f";

  src = fetchFromGitHub {
    owner = "lassekongo83";
    repo = pname;
    rev = version;
    sha256 = "sha256-GqphWcWYf8XBPAQ9MWPGZ5Z0icKAMhJFxNHYecd7t/U=";
  };

  nativeBuildInputs = [ meson ninja sassc ];

  meta = with lib; {
    description = "The theme from libadwaita ported to GTK-3";
    homepage = "https://github.com/lassekongo83/adw-gtk3";
    license = licenses.lgpl21;
    platforms = platforms.linux;
  };
}
