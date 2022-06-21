{ stdenv, lib, fetchurl, bison, flex, perl, libpng, giflib, libjpeg, alsaLib, readline, libGLU, libGL, libXaw, ffmpeg, file, dos2unix, texinfo, doxygen
, xa
, pkgconfig, gtk2, SDL2, autoreconfHook, makeDesktopItem
}:

stdenv.mkDerivation rec {
  name = "vice-${version}";
  version = "3.4";

  src = fetchurl {
    url = "mirror://sourceforge/vice-emu/vice-${version}.tar.gz";
    sha256 = "1svsw3z18nsj3vmpxdp456y79xsj9f1k405r07zd336kccf0rl2b";
  };

  buildInputs = [ bison ffmpeg flex perl libpng giflib libjpeg alsaLib readline libGLU libGL xa file dos2unix texinfo doxygen
    pkgconfig gtk2 SDL2 autoreconfHook libXaw ];
  dontDisableStatic = true;
  configureFlags = [ "--enable-external-ffmpeg" ];

  desktopItem = makeDesktopItem {
    name = "vice";
    exec = "x64";
    comment = "Commodore 64 emulator";
    desktopName = "VICE";
    genericName = "Commodore 64 emulator";
    categories = [ "Application" "Emulator" ];
  };

  preBuild = ''
    for i in src/resid src/resid-dtv
    do
        mkdir -pv $i/src
        ln -sv ../../wrap-u-ar.sh $i/src
    done
  '';

  #NIX_LDFLAGS = "-lX11 -L${libX11}/lib";

  postInstall = ''
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications
  '';

  meta = {
    description = "Commodore 64, 128 and other emulators";
    homepage = "http://www.viceteam.org";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.tokudan ];
    platforms = lib.platforms.linux;
  };
}
