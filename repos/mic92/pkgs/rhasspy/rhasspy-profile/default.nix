{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, pydash
, aiofiles
, aiohttp
, json5
}:

buildPythonPackage rec {
  pname = "rhasspy-profile";
  version = "0.1.4";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "rhasspy-profile";
    rev = "b7f939818fb72dd4a9acb7cc074c95daa48b1aa3";
    sha256 = "016fy67w0q1c2nwzbb6i0hyfhkmn88z8wg9zf8mwaywwjkm4dm6q";
  };

  postPatch = ''
    sed -i "s/aiofiles==.*/aiofiles/" requirements.txt
    sed -i "s/json5==.*/json5/" requirements.txt
  '';

  propagatedBuildInputs = [
    pydash
    aiofiles
    aiohttp
    json5
  ];

  meta = with lib; {
    description = "Python library for Rhasspy settings";
    homepage = "https://github.com/rhasspy/rhasspy-profile";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
