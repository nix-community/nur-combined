{ stdenv, lib, fetchFromGitHub, autoconf, autoconf-archive, automake, pkgconfig, alsaLib, SDL2, SDL2_net, libGL, libGLU, libogg, opusfile }:

stdenv.mkDerivation rec {
  pname = "dosbox-staging";
  version = "unstable-2020-04-19";

  src = fetchFromGitHub {
    owner = "dreamer";
    repo = pname;
    rev = "871556d57fbb494b296d81f148f7a09444d01c83";
    sha256 = "04790gffrzl4s7s50lxghcn7sd5z0kgw57mbv5y6bmkhp86qi0x9";
  };

  hardeningDisable = [ "format" ];

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ autoconf autoconf-archive automake SDL2 libGL libGLU libogg opusfile alsaLib SDL2_net ];

  preConfigure = "./autogen.sh";

  preBuild = ''
    buildFlagsArray=( "CXXFLAGS=-O3 -DNDEBUG" )
  '';

  postInstall = ''
    mkdir -p $out/share/applications
    cp $src/contrib/linux/dosbox-staging.desktop $out/share/applications/dosbox-staging.desktop
    mkdir -p $out/share/icons/hicolor/scalable/apps
    cp $src/contrib/icons/dosbox-staging.svg $out/share/icons/hicolor/scalable/apps/dosbox-staging.svg
  '';

  meta = with stdenv.lib; {
    description = "A modernized DOS emulator";
    homepage = "https://github.com/dreamer/dosbox-staging";
    license = licenses.gpl2;
    maintainers = with maintainers; [ joshuafern ];
    platforms = platforms.unix;
  };
}
