{ stdenvNoCC, lib, fetchurl, p7zip }:

stdenvNoCC.mkDerivation rec {
  pname = "usa-osm-topo-routable";
  version = "33";

  srcs = [
    (fetchurl {
      url = "http://gmaptool.eu/sites/default/files/download/USA_OSM_Topo_v${version}.7z.001";
      sha256 = "0603ja9j0m7yi88ykq60ix4savqr74nc4dhrjfhjidxm0zrdc48k";
    })
    (fetchurl {
      url = "http://gmaptool.eu/sites/default/files/download/USA_OSM_Topo_v${version}.7z.002";
      sha256 = "1q9l03fqnxd6rm6w77sjb1wd9cqc62ilraplrz2a0fsnf2n4wx5n";
    })
    (fetchurl {
      url = "http://gmaptool.eu/sites/default/files/download/USA_OSM_Topo_v${version}.7z.003";
      sha256 = "1kk82qp6xmsjh2s9jfjmvpa5ckiqhkl5a3hazamdaxk30zg3d0h5";
    })
    (fetchurl {
      url = "http://gmaptool.eu/sites/default/files/download/USA_OSM_Topo_v${version}.7z.004";
      sha256 = "1bp73mnd6bcwj9clps6knvrmpsykx9akqv31jai7kg2x500zq79m";
    })
    (fetchurl {
      url = "http://gmaptool.eu/sites/default/files/download/USA_OSM_Topo_v${version}.7z.005";
      sha256 = "1wz1kxinh6fh092zm6wzknkp46xdbnmdnd9mbclx1a2q6fid74x2";
    })
  ];

  unpackPhase = lib.concatMapStringsSep "\n" (src: "ln -s ${src} ${src.name}") srcs;

  nativeBuildInputs = [ p7zip ];

  installPhase = "7z x USA_OSM_Topo_v${version}.7z.001 -o$out";

  meta = with lib; {
    description = "USA OSM Topo Routable";
    homepage = "https://www.gmaptool.eu/en/content/usa-osm-topo-routable";
    license = licenses.cc-by-nc-40;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
