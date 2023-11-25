{ lib
, buildPythonPackage
, fetchFromGitHub
, aiohttp
, async-timeout
}:

buildPythonPackage rec {
  pname = "pymiele";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "astrandb";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-qyEuB2vwGiGYWExIm3NNyzDCyY20mFF22TXLTABC2yo=";
  };

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
