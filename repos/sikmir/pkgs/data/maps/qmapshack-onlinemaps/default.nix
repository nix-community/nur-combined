{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "qmapshack-onlinemaps";
  version = "2020-07-25";

  src = fetchzip {
    url = "http://www.mtb-touring.net/wordpress/wp-content/uploads/Onlinemaps.zip";
    sha256 = "1khfmbrq85bb2gq2b0c22qsjqk3740x7lbsv2zwqnflfjckqlpgi";
    stripRoot = false;
  };

  installPhase = ''
    install -dm755 $out/share/qmapshack/Maps
    cp -r $src/* $out/share/qmapshack/Maps
  '';

  meta = with stdenv.lib; {
    description = "Onlinekarten einbinden";
    homepage = "http://www.mtb-touring.net/qms/onlinekarten-einbinden/";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
