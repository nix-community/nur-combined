{ lib, python38Packages, fetchFromGitHub }:

with python38Packages;

buildPythonPackage rec {
  pname = "downloader-cli";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "deepjyoti30";
    repo = pname;
    rev = version;
    sha256 = "sha256-WDbMmVv9WvxqH1TfGzM9qRS5zF803N7Q6tvy3Wbdcw8=";
  };

  buildInputs = with python38Packages; [ urllib3 ];

  meta = with lib; {
    description =
      "A simple downloader written in Python with an awesome customizable progressbar";
    homepage = "https://github.com/deepjyoti30/downloader-cli";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
