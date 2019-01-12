{ stdenv, fetchgit, fetchpatch, pkgconfig, libX11, ncurses, libXext, libXft, fontconfig }:

stdenv.mkDerivation rec {
  name = "st-${version}";
  version = "3be4cf11d79ca87ff1fbbb57801913ec6f822429";

  src = fetchgit {
    url = git://git.suckless.org/st;
    rev = version;
    sha256 = "0i3m7wv0bbagl0gm7mif9sw4mpf6m36i2pr3r21cz31vfjqckwsa";
  };

  patches = [
    ./st-fix-deletekey.patch

    (fetchpatch {
      url = https://st.suckless.org/patches/scrollback/st-scrollback-20181224-096b125.diff;
      sha256 = "01901l9q0naj5plrb68qir54jif9d0a0hag7brjhvg36rpv123lg";
    })

    (fetchpatch {
      url = https://st.suckless.org/patches/scrollback/st-scrollback-mouse-0.8.diff;
      sha256 = "19nwskj7nycym8s9m6w0jrxjqgz6azggbq5bmk4h7hgbc7xfgzbc";
    })

    (fetchpatch {
      url = https://st.suckless.org/patches/spoiler/st-spoiler-20180309-c5ba9c0.diff;
      sha256 = "0ar1mhkxppmfgv4f9ifik3zgm11kgxa22g5837c6x8kl1s5ykxwp";
    })
  ];

  prePatch = "cp ${./config.h} config.def.h";

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libX11 ncurses libXext libXft fontconfig ];

  installPhase = ''
    TERMINFO=$out/share/terminfo make install PREFIX=$out
  '';
}
