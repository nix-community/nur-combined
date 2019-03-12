{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig
, wayland, wayland-protocols, ffmpeg_4, x264, libav
}:

stdenv.mkDerivation rec {
  pname = "wf-recorder-unstable";
  version = "2019-03-10";

  src = fetchFromGitHub {
    owner = "ammen99";
    repo = "wf-recorder";
    rev = "689d1389394afbd6ced99fd7f60f5f3bd3d01d2f";
    sha256 = "08xpg6qfxif0dxv4zdi4qyl2qsrcbd3nkmg0xgyvjds782kslpsh";
  };

  nativeBuildInputs = [ meson ninja pkgconfig ];
  buildInputs = [ wayland wayland-protocols ffmpeg_4 x264 libav ];

  meta = with stdenv.lib; {
    description = "Utility program for screen recording of wlroots-based compositors";
    homepage = "https://github.com/ammen99/wf-recorder";
    license = licenses.mit;
    maintainers = with maintainers; [ dywedir ];
    platforms = platforms.linux;
  };
}
