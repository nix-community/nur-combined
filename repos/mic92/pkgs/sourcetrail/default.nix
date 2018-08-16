{ stdenv, fetchurl, autoPatchelfHook
, icu, zlib, expat, dbus, libheimdal, openssl_1_0_2
}:

stdenv.mkDerivation rec {
  version = "2018.2.77";
  name = "sourcetrail-${version}";

  src = fetchurl {
    name = "sourcetrail-${version}.tar.gz";
    url = "https://www.sourcetrail.com/downloads/${version}/linux/64bit/";
    sha256 = "06g7mv66gfbcrf1im6yhd3v4m53jxq6dyq6k80388mpn31cfkpqy";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [ 
    zlib expat dbus stdenv.cc.cc
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/{sourcetrail,applications,pixmaps} $out/bin
    cp -r . $out/share/sourcetrail

    rm $out/share/sourcetrail/lib/platforms/{libqeglfs.so,libqwebgl.so}

    ln -sf ${openssl_1_0_2}/lib/libssl.so $out/share/sourcetrail/lib/libssl.so

    ln -s $out/share/sourcetrail/gui/icon/logo_1024_1024.png $out/share/pixmaps/sourcetrail.png
    ln -s $out/share/sourcetrail/sourcetrail.desktop $out/share/applications/
    ln -s $out/share/sourcetrail/Sourcetrail.sh $out/bin/sourcetrail

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "A cross-platform source explorer for C/C++ and Java";
    homepage = http://sourcetrail.com;
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ maintainers.mic92 ];
  };
}
