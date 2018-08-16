{ stdenv, fetchgit, fetchpatch, pkgconfig, libX11, ncurses, libXext, libXft, fontconfig }:

stdenv.mkDerivation rec {
  name = "st-${version}";
  version = "1f24bde82b19912c080fbb4a0b153a248cd6c6ea";

  src = fetchgit {
    url = git://git.suckless.org/st;
    rev = version;
    sha256 = "168vx8ndj9lwaq4i77xc6pi222yac2bwv134dnp9j86bpj6jzpmi";
  };

  patches = [
    ./st-fix-deletekey.patch

    (fetchpatch {
      url = https://st.suckless.org/patches/scrollback/st-scrollback-20170329-149c0d3.diff;
      sha256 = "01136cvv7q0b6svwa922k85053659zsy2vh8kxqc8p56zldx34bg";
    })

    (fetchpatch {
      url = https://st.suckless.org/patches/scrollback/st-scrollback-mouse-20170427-5a10aca.diff;
      sha256 = "0z86xv920xlnvzi8a46zvbc9n2s1kbj33jp1rxq6p7dh80h7hjv7";
    })

    (fetchpatch {
      url = https://st.suckless.org/patches/spoiler/st-spoiler-20170802-e2ee5ee.diff;
      sha256 = "1n3mdh09ci8qd8wdvw8s6imw5yp006268wy27c7j61dnahr3dv29";
    })
  ];

  prePatch = "cp ${./config.h} config.def.h";

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libX11 ncurses libXext libXft fontconfig ];

  installPhase = ''
    TERMINFO=$out/share/terminfo make install PREFIX=$out
  '';
}
