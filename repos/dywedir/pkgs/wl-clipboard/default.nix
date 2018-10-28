{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig
, wayland, wayland-protocols }:

stdenv.mkDerivation rec {
  name = "wl-clipboard-unstable-${version}";
  version = "2018-10-27";

  src = fetchFromGitHub {
    owner = "bugaevc";
    repo = "wl-clipboard";
    rev = "f1e90fe64554dffdb533e12ed88524e3dd236860";
    sha256 = "0f9qpjgxa4vp9cvdvigdp0my37qyym8zpa0h7qlckisalp411hbj";
  };

  nativeBuildInputs = [ meson ninja pkgconfig wayland wayland-protocols ];

  meta = with stdenv.lib; {
    description = "Command-line copy/paste utilities for Wayland";
    homepage = https://github.com/bugaevc/wl-clipboard;
    license = licenses.gpl3;
    maintainers = with maintainers; [ dywedir ];
    platforms = platforms.linux;
  };
}
