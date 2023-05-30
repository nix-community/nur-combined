{ lib
, python3
, fetchFromGitHub
, bing-image-creator
}:

python3.pkgs.buildPythonPackage rec {
  pname = "edge-gpt";
  version = "0.6.10";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "acheong08";
    repo = "EdgeGPT";
    rev = version;
    hash = "sha256-sZ3dXy5wXojcdaR/zWMWC59JDVJT6ODo+TIL5kHyk5k=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    requests
    certifi
    httpx
    rich
    websockets
    regex
    prompt-toolkit
    bing-image-creator
  ];

  pythonImportsCheck = [
    "EdgeGPT"
    "ImageGen"
  ];

  meta = with lib; {
    description = "Reverse engineered API of Microsoft's Bing Chat AI";
    homepage = "https://github.com/acheong08/EdgeGPT";
    license = licenses.unlicense;
  };
}
