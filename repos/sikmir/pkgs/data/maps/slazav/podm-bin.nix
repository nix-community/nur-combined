{ stdenv, fetchurl }:
fetchurl {
  name = "slazav-podm-2020-08-05";
  url = "http://slazav.mccme.ru/maps/podm/podm.img";
  sha256 = "0cny4hjmkx27fbpb3bbbbha7mb81xm0wp94kdilils735pmdwfk9";

  downloadToTemp = true;
  recursiveHash = true;

  postFetch = "install -Dm644 $downloadedFile $out/podm.img";

  meta = with stdenv.lib; {
    homepage = "http://slazav.mccme.ru/maps/podm/index.htm";
    description = "Карты Подмосковья";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
