{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "flask-rangerequest";
  version = "0.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "heartsucker";
    repo = "flask-rangerequest";
    rev = "1ab9efb9fda73e1c6e1d17b2ff039eafa8b2caee";
    hash = "sha256-eFdpSyFCw4/mRrNbWwHbCQ7YgkUL+RevMlmyLisazBI=";
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = [ python3Packages.flask ];

  nativeCheckInputs = [ python3Packages.pytestCheckHook ];

  pythonImportsCheck = [ "flask_rangerequest" ];

  meta = {
    description = "Range Requests for Flask";
    homepage = "https://github.com/heartsucker/flask-rangerequest";
    license = with lib.licenses; [
      asl20
      mit
    ];
    maintainers = [ lib.maintainers.sikmir ];
  };
})
