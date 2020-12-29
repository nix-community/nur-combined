{ stdenv, fetchurl }:
fetchurl {
  name = "slazav-podm-2020-12-03";
  url = "http://slazav.xyz/maps/podm/all_podm.img";
  sha256 = "0ils8dm81dmc937fqbdc0a5d8hwj6fx6ja8aci1vjg295fc77nk0";

  downloadToTemp = true;
  recursiveHash = true;

  postFetch = "install -Dm644 $downloadedFile $out/all_podm.img";

  meta = with stdenv.lib; {
    homepage = "http://slazav.xyz/maps/podm_txt.htm";
    description = "Карты Подмосковья";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
