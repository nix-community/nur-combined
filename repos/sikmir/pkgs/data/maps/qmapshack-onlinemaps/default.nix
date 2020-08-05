{ lib, fetchzip }:

fetchzip {
  name = "qmapshack-onlinemaps-2020-07-25";

  url = "http://www.mtb-touring.net/wordpress/wp-content/uploads/Onlinemaps.zip";
  sha256 = "1khfmbrq85bb2gq2b0c22qsjqk3740x7lbsv2zwqnflfjckqlpgi";
  stripRoot = false;

  meta = with lib; {
    description = "Onlinekarten einbinden";
    homepage = "http://www.mtb-touring.net/qms/onlinekarten-einbinden/";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
