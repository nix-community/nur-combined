{ lib, fetchzip }:

fetchzip {
  name = "qmapshack-onlinemaps-2020-08-09";

  url = "http://www.mtb-touring.net/wp-content/uploads/Onlinemaps.zip";
  sha256 = "06pwn8l2wr3h0m70pn1ngzs5fvabps1wiqilgdxiw43dhiy94rv9";
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
