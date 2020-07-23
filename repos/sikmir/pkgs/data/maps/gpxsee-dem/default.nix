{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation {
  pname = "gpxsee-dem";
  version = "2014-05-25";

  srcs = [
    (
      fetchurl {
        url = "http://viewfinderpanoramas.org/dem1/O35.zip";
        sha256 = "0wc5l7vcm33qkmbmjaij2mkxv59922150qjabjhhxqaf7xxv3q65";
      }
    )
    (
      fetchurl {
        url = "http://viewfinderpanoramas.org/dem1/P35.zip";
        sha256 = "093zz7yx8kcykip83k8gzby9l6lx03nsvzjw21axjlbd48fl26ac";
      }
    )
    (
      fetchurl {
        url = "http://viewfinderpanoramas.org/dem1/P36.zip";
        sha256 = "15icmvc2md6g9a89ln4ckkclynfhcf21yabfcr7azp7ivy23f46i";
      }
    )
    (
      fetchurl {
        url = "http://viewfinderpanoramas.org/dem1/Q35.zip";
        sha256 = "0lvm43v03i80v6b9phwbd3mdhqi6y2iklgp4cc0qx56pg7z6wdaa";
      }
    )
    (
      fetchurl {
        url = "http://viewfinderpanoramas.org/dem1/Q36.zip";
        sha256 = "1l05ljhxdyh2lb5ydlr4xfjbx4lvg6g2a2fg097yqhw95n3xxqv1";
      }
    )
  ];

  unpackPhase = "for src in $srcs; do ${unzip}/bin/unzip $src; done";

  dontConfigure = true;
  dontBuild = true;

  preferLocalBuild = true;

  installPhase = ''
    install -Dm644 **/*.hgt -t $out/share/gpxsee/DEM
  '';

  meta = with stdenv.lib; {
    description = "Digital Elevation Data";
    homepage = "http://www.viewfinderpanoramas.org/";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
