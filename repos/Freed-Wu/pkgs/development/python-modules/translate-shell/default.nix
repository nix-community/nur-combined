{ mySources
, python3
, lib
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.translate-shell) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.6";
  propagatedBuildInputs = [
    aiohttp
    colorama
    keyring
    langdetect
    jedi
    pynotifier
    rich
    pystardict
    repl-python-wakatime
    pygls
    pyyaml
  ];
  nativeBuildInputs = [
    setuptools-generate
    setuptools-scm
  ];
  pythonImportsCheck = [
    "translate_shell"
  ];

  meta = with lib; {
    mainProgram = "trans";
    homepage = "https://translate-shell.readthedocs.io";
    description = "Translate text by google, bing, youdaozhiyun, haici, stardict, etc at same time from CLI, GUI (GNU/Linux, Android, macOS and Windows), REPL, python, shell and vim";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
