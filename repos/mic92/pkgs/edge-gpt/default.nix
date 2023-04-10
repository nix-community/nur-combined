{ lib
, python3
, fetchFromGitHub
, runtimeShell
}:

python3.pkgs.buildPythonApplication rec {
  pname = "edge-gpt";
  version = "0.1.22.1";
  format = "setuptools";

  # https://github.com/acheong08/EdgeGPT/pull/286
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "EdgeGPT";
    rev = "3672e45946d58accf65ee0b393ca3c682909cf08";
    hash = "sha256-IFd5HgDErNbpY0d+GxnQgT2dMjLDCQoyFil35kxzDQQ=";
  };
  #src = fetchFromGitHub {
  #  owner = "acheong08";
  #  repo = "EdgeGPT";
  #  rev = version;
  #  hash = "sha256-LKYYqtzLqV6YubpnHv628taO4FkG5eUomCg71JyxWg8=";
  #};

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
    maintainers = with maintainers; [ ];
  };
}
