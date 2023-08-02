{ lib
, python3
, fetchFromGitHub
, bing-image-creator
}:

python3.pkgs.buildPythonPackage rec {
  pname = "edge-gpt";
  version = "0.13.1";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "acheong08";
    repo = "EdgeGPT";
    rev = version;
    hash = "sha256-nfPTph04CsWWQyfljteFdn6q1RpetYwz6MaD3s3V+ow=";
  };

  postPatch = ''
    # we don't need the socks feature
    # "httpx[socks]>=0.24.0",
    sed -i -e 's/httpx.*/httpx",/' setup.py
  '';

  propagatedBuildInputs = with python3.pkgs; [
    requests
    aiofiles
    certifi
    httpx
    rich
    websockets
    prompt-toolkit
    bing-image-creator
  ];

  checkInputs = [ python3.pkgs.pytest ];
  doCheck = false; # requires internet

  pythonImportsCheck = [
    "EdgeGPT"
    "EdgeGPT.ImageGen"
  ];

  meta = with lib; {
    description = "Reverse engineered API of Microsoft's Bing Chat AI";
    homepage = "https://github.com/acheong08/EdgeGPT";
    license = licenses.unlicense;
  };
}
