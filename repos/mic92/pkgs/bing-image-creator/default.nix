{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonPackage rec {
  pname = "bing-image-creator";
  version = "0.4.4";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "acheong08";
    repo = "BingImageCreator";
    rev = version;
    hash = "sha256-ox36RMmy0DopYfA2C7af5On9AkQd6zVkkGwq1sLpIq8=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    regex
    requests
    aiohttp
    httpx
  ];

  pythonImportsCheck = [ "BingImageCreator" ];

  meta = with lib; {
    description = "High quality image generation by Microsoft. Reverse engineered API";
    homepage = "https://github.com/acheong08/BingImageCreator";
    license = licenses.unlicense;
  };
}
