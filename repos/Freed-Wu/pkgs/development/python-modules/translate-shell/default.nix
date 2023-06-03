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
    homepage = "https://translate-shell.readthedocs.io";
    description = "Translate text by google, bing, youdaozhiyun, haici, stardict, etc at same time from CLI, GUI (GNU/Linux, Android, macOS and Windows), REPL, python, shell and vim";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
    platforms = platforms.unix;
  };
}
