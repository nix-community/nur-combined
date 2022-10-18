{ lib, fetchPypi, buildPythonPackage, requests, click, pillow, python-dotenv
, pyperclip }:

buildPythonPackage rec {
  pname = "images-upload-cli";
  version = "1.0.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-aIaYbxGL5EQ9a9RgE6/GSZTBW1A+D3BpQOxQrHYLOVg=";
  };

  pythonImportsCheck = [ "images_upload_cli" ];

  propagatedBuildInputs = [ requests click pillow python-dotenv pyperclip ];

  prePatch = ''
    substituteInPlace setup.py \
        --replace 'python-dotenv>=0.20.0,<0.21.0' 'python-dotenv>=0'
  '';

  meta = with lib; {
    description = "Upload images via APIs";
    homepage = "https://github.com/DeadNews/images-upload-cli";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
