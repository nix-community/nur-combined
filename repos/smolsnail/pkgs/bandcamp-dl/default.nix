{ buildPythonPackage, fetchPypi, lib, beautifulsoup4, chardet, demjson3, docopt
, lxml, mock, mutagen, requests, unicode-slugify }:

buildPythonPackage rec {
  pname = "bandcamp-downloader";
  version = "0.0.12";

  src = fetchPypi {
    inherit pname version;
    sha256 = "176a7aaed1f811b5a3ca3354a1078e51196ab1b7c85964f9faaf58bdf0a50c63";
  };

  propagatedBuildInputs = [
    beautifulsoup4
    chardet
    demjson3
    docopt
    lxml
    mock
    mutagen
    requests
    unicode-slugify
  ];

  meta = with lib; {
    description = "download audio from BandCamp.com";
    homepage = "https://github.com/iheanyi/bandcamp-dl";
    license = licenses.unlicense;
    platforms = platforms.all;
  };
}
