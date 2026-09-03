{
  lib,
  fetchPypi,
  buildPythonPackage,

  # build-system
  hatchling,
  uv-dynamic-versioning,

  # dependencies
  click,
  httpx,
  loguru,
  pillow,
  pyperclip,
  python-dotenv,
  rich,

  # tests
  versionCheckHook,
}:

buildPythonPackage rec {
  pname = "images-upload-cli";
  version = "3.0.6";
  pyproject = true;

  src = fetchPypi {
    pname = "images_upload_cli";
    inherit version;
    hash = "sha256-vydsMVVBFrr0kEnNx6ZazdhNvHgdMn1xQcVz9DoHems=";
  };

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = [
    click
    httpx
    loguru
    pillow
    pyperclip
    python-dotenv
    rich
  ];

  pythonImportsCheck = [ "images_upload_cli" ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Upload images via APIs";
    homepage = "https://github.com/DeadNews/images-upload-cli";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "images-upload-cli";
  };
}
