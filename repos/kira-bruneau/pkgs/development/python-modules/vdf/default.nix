{ lib
, buildPythonPackage
, fetchFromGitHub
, mock
, pytestCheckHook
, nix-update-script
}:

buildPythonPackage rec {
  pname = "vdf";
  version = "3.4";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "ValvePython";
    repo = "vdf";
    rev = "refs/tags/v${version}";
    hash = "sha256-6ozglzZZNKDtADkHwxX2Zsnkh6BE8WbcRcC9HkTTgPU=";
  };

  nativeCheckInputs = [ mock pytestCheckHook ];

  pythonImportsCheck = [ "vdf" ];

  # The default python updater doesn't work because pygls doesn't use
  # GitHub releases, only tags
  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Library for working with Valve's VDF text format";
    homepage = "https://github.com/ValvePython/vdf";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
  };
}
