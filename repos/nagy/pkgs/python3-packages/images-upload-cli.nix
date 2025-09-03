{
  lib,
  fetchPypi,
  buildPythonPackage,
  requests,
  click,
  pillow,
  python-dotenv,
  pyperclip,
  httpx,
  loguru,
  rich,
  uv-dynamic-versioning,
}:

buildPythonPackage rec {
  pname = "images-upload-cli";
  version = "3.0.6";
  format = "pyproject";

  src = fetchPypi {
    pname = "images_upload_cli";
    inherit version;
    hash = "sha256-vydsMVVBFrr0kEnNx6ZazdhNvHgdMn1xQcVz9DoHems=";
  };

  pythonImportsCheck = [ "images_upload_cli" ];

  propagatedBuildInputs = [
    requests
    click
    pillow
    python-dotenv
    pyperclip
    uv-dynamic-versioning
    httpx
    loguru
    rich
  ];

  meta = with lib; {
    description = "Upload images via APIs";
    homepage = "https://github.com/DeadNews/images-upload-cli";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
