{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "qmapshack-onlinemaps";
  version = "2019-12-26";

  src = fetchzip {
    url = "http://www.mtb-touring.net/wordpress/wp-content/uploads/Onlinemaps.zip";
    sha256 = "0rffdhxs76hfm4gipz63sc3b56gi36lfzrfz57bzpr6zshb5wxrd";
    stripRoot = false;
  };

  installPhase = ''
    install -dm755 "$out/share/qmapshack/Maps"
    cp -r $src/* "$out/share/qmapshack/Maps"
  '';

  meta = with stdenv.lib; {
    description = "Onlinekarten einbinden";
    homepage = "http://www.mtb-touring.net/qms/onlinekarten-einbinden/";
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
