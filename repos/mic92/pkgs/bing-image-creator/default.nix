{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonPackage rec {
  pname = "bing-image-creator";
  version = "0.4.1";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "acheong08";
    repo = "BingImageCreator";
    rev = version;
    hash = "sha256-C5yzdVnbf1XryQe3KRj4G1cguB94whGdMpH1+Jcv6Ts=";
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
