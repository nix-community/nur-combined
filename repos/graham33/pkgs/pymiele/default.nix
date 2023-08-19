{ lib
, buildPythonPackage
, fetchFromGitHub
, aiohttp
, async-timeout
}:

buildPythonPackage rec {
  pname = "pymiele";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "astrandb";
    repo = pname;
    rev = "73585522fdf35e662f19486be82a161bd8a9b8fa";
    sha256 = "sha256-fu1FhxKk1avHGl5NRDWpgXhyRKfo2PvJFGPLMMW9OyQ=";
  };

  patches = [
    ./requirements.patch
  ];

  postPatch = ''
    rm Makefile
  '';

  propagatedBuildInputs = [
    aiohttp
    async-timeout
  ];

  meta = with lib; {
    homepage = "https://github.com/astrandb/pymiele";
    license = licenses.mit;
    description = "Python library for Miele integration with Home Assistant.";
    maintainers = with maintainers; [ graham33 ];
  };
}
