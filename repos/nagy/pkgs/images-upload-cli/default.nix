{ lib, fetchPypi, buildPythonPackage, requests, click, pillow, python-dotenv
, pyperclip, testers, images-upload-cli, poetry-core, poetry-dynamic-versioning
, httpx, pythonRelaxDepsHook }:

buildPythonPackage rec {
  pname = "images-upload-cli";
  version = "2.0.0";
  format = "pyproject";

  src = fetchPypi {
    pname = "images_upload_cli";
    inherit version;
    hash = "sha256-XuaqLc/WhAPEkVqPSKs+SrLNHXlIuZUe+BNTpH1Af14=";
  };

  nativeBuildInputs = [ pythonRelaxDepsHook poetry-core ];

  pythonImportsCheck = [ "images_upload_cli" ];

  pythonRelaxDeps = [ "requests" "pillow" "httpx" ];

  propagatedBuildInputs = [
    requests
    click
    pillow
    python-dotenv
    pyperclip
    poetry-dynamic-versioning
    httpx
  ];

  passthru.tests.version = testers.testVersion { package = images-upload-cli; };

  meta = with lib; {
    description = "Upload images via APIs";
    homepage = "https://github.com/DeadNews/images-upload-cli";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
