{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  prompt-toolkit,
  pygments,
  nbformat,
  jupyter_client,
  typing-extensions,
  fastjsonschema,
  platformdirs,
  pyperclip,
  imagesize,
  markdown-it-py,
  linkify-it-py,
  mdit-py-plugins,
  flatlatex,
  timg,
  pillow,
  sixelcrop,
  universal-pathlib,
  fsspec,
  jupytext,
  pytest-asyncio,
  pytest-cov,
  coverage,
  python-magic,
  html2text,
  pytestCheckHook,
  aresponses,
  pythonOlder,
}:
buildPythonPackage rec {
  pname = "euporie";
  version = "2.8.6";
  format = "pyproject";

  disabled = pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "joouha";
    repo = "euporie";
    rev = "v${version}";
    hash = "sha256-7wsx6pTpKeLyt/JDrQRL9QjlqiHPq8GtJuMhnQ2Rd0g=";
  };

  build-system = [hatchling];

  dependencies = [
    prompt-toolkit
    pygments
    nbformat
    jupyter_client
    typing-extensions
    fastjsonschema
    platformdirs
    pyperclip
    imagesize
    markdown-it-py
    linkify-it-py
    mdit-py-plugins
    flatlatex
    timg
    pillow
    sixelcrop
    universal-pathlib
    fsspec
    jupytext
  ];

  pythonRelaxDeps = [
    "platformdirs"
    "timg"
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  nativeCheckInputs = [
    pytestCheckHook
    aresponses
    pytest-asyncio
    pytest-cov
    coverage
    python-magic
    html2text
  ];

  pythonImportsCheck = [
    "euporie"
  ];

  meta = with lib; {
    description = "Euporie is a suite of terminal applications for interacting with Jupyter kernels";
    homepage = "https://github.com/joouha/euporie";
    license = licenses.mit;
    maintainers = with maintainers; [euxane renesat];
  };
}
