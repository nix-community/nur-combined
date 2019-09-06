{ stdenv, fetchgit, fetchpatch, pkgconfig, libX11, ncurses, libXext, libXft, fontconfig }:

stdenv.mkDerivation rec {
  name = "st-${version}";
  version = "0.8.2";

  src = fetchgit {
    url = git://git.suckless.org/st;
    rev = version;
    sha256 = "0403r8d4krfs5022xzanwam1qx65spgz5y8v8240ygmcfngfahzy";
  };

  patches = [
    ./st-fix-deletekey.patch

    (fetchpatch {
      url = https://st.suckless.org/patches/scrollback/st-scrollback-0.8.2.diff;
      sha256 = "1qwdl1fyl2rkw67ml80gyzgwk3mvcp332ijriqx3dp846n75d48d";
    })

    (fetchpatch {
      url = https://st.suckless.org/patches/scrollback/st-scrollback-mouse-0.8.2.diff;
      sha256 = "0sk6qldb1b1rik2wzra29lsaas1q8qj2xcp6da8n9zwbsrllmb48";
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
