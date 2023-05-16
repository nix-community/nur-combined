{ lib, fetchPypi, buildPythonPackage, requests, click, pillow, python-dotenv
, pyperclip, testers, images-upload-cli, poetry-core, poetry-dynamic-versioning, pythonRelaxDepsHook
}:

buildPythonPackage rec {
  pname = "images-upload-cli";
  version = "1.1.3";
  format = "pyproject";

  src = fetchPypi {
    pname = "images_upload_cli";
    inherit version;
    sha256 = "sha256-6CUG74gS+b/M2+csIwkZWIBQ4QDGY60rsWIKVVFDiIU=";
  };

  nativeBuildInputs = [ pythonRelaxDepsHook poetry-core ];

  pythonImportsCheck = [ "images_upload_cli" ];

  pythonRelaxDeps = [ "requests" "pillow" ];

  propagatedBuildInputs =
    [ requests click pillow python-dotenv pyperclip poetry-dynamic-versioning ];

  passthru.tests.version = testers.testVersion { package = images-upload-cli; };

  meta = with lib; {
    description = "Upload images via APIs";
    homepage = "https://github.com/DeadNews/images-upload-cli";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
