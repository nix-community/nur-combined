{ lib, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "youtube-search";
  version = "1.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-um9ZlgGRFA4U8EQHJUON2vdAP1JEeFT6Jciy+CGP0Rg=";
  };

  buildInputs = [ requests ];

  meta = with lib; {
    description =
      "Tool for searching for youtube videos to avoid using their heavily rate-limited API";
    homepage = "https://github.com/joetats/youtube_search";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
