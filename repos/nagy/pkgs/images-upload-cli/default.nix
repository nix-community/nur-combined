{ lib, fetchPypi, buildPythonPackage, requests, click, pillow, python-dotenv
, pyperclip, testers, images-upload-cli }:

buildPythonPackage rec {
  pname = "images-upload-cli";
  version = "1.1.0";

  src = fetchPypi {
    pname = "images_upload_cli";
    inherit version;
    sha256 = "sha256-PcShOhUI/FQgAfNFyaLi/9+HYW32ic2/s+fHHX3QErY=";
  };

  pythonImportsCheck = [ "images_upload_cli" ];

  propagatedBuildInputs = [ requests click pillow python-dotenv pyperclip ];

  passthru.tests.version = testers.testVersion {
    package = images-upload-cli;
  };

  meta = with lib; {
    description = "Upload images via APIs";
    homepage = "https://github.com/DeadNews/images-upload-cli";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
