{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonPackage rec {
  pname = "bing-image-creator";
  version = "0.3.0";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "acheong08";
    repo = "BingImageCreator";
    rev = version;
    hash = "sha256-NfOGwEd27Ir70Zdo6dUvm1/mu5O6WEDR/2uwEPqPCk4=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    regex
    requests
    aiohttp
  ];

  pythonImportsCheck = [ "BingImageCreator" ];

  meta = with lib; {
    description = "High quality image generation by Microsoft. Reverse engineered API";
    homepage = "https://github.com/acheong08/BingImageCreator";
    license = licenses.unlicense;
  };
}
