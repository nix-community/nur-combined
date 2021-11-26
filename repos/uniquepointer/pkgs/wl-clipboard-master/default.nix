{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, wayland
, wayland-protocols
}:

stdenv.mkDerivation rec {
  pname = "wl-clipboard";
  version = "master";

  src = fetchFromGitHub {
    owner = "bugaevc";
    repo = "wl-clipboard";
    rev = "297ab2a6fdd34c15c5eb3eb427be8daf753bcfd7";
    sha256 = "DRs4Fxc4AL7fC+hKM9/km/OmtQWrrrM/gMMmZn7HXBQ=";
  };


  buildInputs = [ wayland wayland-protocols pkg-config meson ninja ];

  installPhase = ''
    mkdir -p $out/bin
    cp ./src/wl-copy $out/bin/.
    cp ./src/wl-paste $out/bin/.
  '';

  meta = with lib; {
    description = "Command-line copy/paste utilities for Wayland.";
    homepage = "https://github.com/bugaevc/wl-clipboard";
    license = with licenses; [ gpl3Plus ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ uniquepointer ];
  };
}
