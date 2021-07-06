{ python38Packages
, fetchFromGitHub
, lib
}:

python38Packages.buildPythonPackage rec {
  pname = "downloader-cli";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "deepjyoti30";
    repo = "downloader-cli";
    rev = version;
    sha256 = "sha256-SAhMlrAVkONiXqzUd6c0llWK6Od1aMpAQq+4nVaXaz0=";
  };

  buildInputs = (with python38Packages; [
    urllib3
  ]);

  meta = with lib; {
    description = "A simple downloader with an awesome progressbar";
    homepage = "https://github.com/deepjyoti30/downloader-cli";
    license = licenses.mit;
    maintainers = with maintainers; [ dan4ik605743 ];
    platforms = platforms.linux;
  };
}
