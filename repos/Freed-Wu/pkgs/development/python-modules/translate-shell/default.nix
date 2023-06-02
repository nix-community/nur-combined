{ mySources
, python3
, lib
, setuptools-generate
, repl-python-wakatime
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.translate-shell) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.6";
  propagatedBuildInputs = [
    colorama
    keyring
    langdetect
    # py-notifier
    rich
    # pystardict
    repl-python-wakatime
    pyyaml
  ];
  nativeCheckInputs = [
    setuptools-generate
  ];
  pythonImportsCheck = [
    "translate_shell"
  ];
  meta = with lib; {
    mainProgram = "trans";
  };
}
