{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonPackage rec {
  pname = "edge-gpt";
  version = "0.4.2";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "acheong08";
    repo = "EdgeGPT";
    rev = version;
    hash = "sha256-Ec/BFZZrXp5Kq9ImcFe1EOsqruskczPpO60Mqa5LEXk=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    requests
    certifi
    httpx
    rich
    websockets
    regex
    prompt-toolkit
    (callPackage ./bing-image-creator { })
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
