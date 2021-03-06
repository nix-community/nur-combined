{ lib
, python3Packages
, simber
, pydes
, youtube-search
, downloader-cli
, itunespy
, bs4
}:

with python3Packages;

buildPythonPackage rec {
  pname = "ytmdl";
  version = "2021.3.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-WFXodF9MHf7/Gz3KJDgZqW6PQtCiP4gphomcJFfJLSI=";
  };

  doCheck = false; # NOTE: disable to prevent false fails

  propagatedBuildInputs = [
    simber
    pydes
    youtube-search
    colorama
    itunespy
    downloader-cli
    bs4 # TODO: make a pr that fixes this
    beautifulsoup4 # TODO: make a pr that fixes this
    urllib3
    mutagen
    unidecode
    musicbrainzngs
    rich
    pysocks
    ffmpeg-python
    pyxdg
    lxml
    requests
    youtube-dl
    pycountry
  ];

  meta = with lib; {
    description =
      "A simple app to get songs from YouTube in mp3 format with artist name, album name etc from sources like iTunes, LastFM, Deezer, Gaana etc.";
    homepage = "https://github.com/deepjyoti30/ytmdl";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
