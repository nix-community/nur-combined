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
  version = "2.8.5";
  format = "pyproject";

  disabled = pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "joouha";
    repo = "euporie";
    rev = "v${version}";
    hash = "sha256-dnaVb+8gH5Vu3P9jkkSSYBBG6duuwUgmP1OUjF14pQ0=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "\"timg~=1.1.6\"," "" \
      --replace-fail "platformdirs~=3.5" "platformdirs"
    #   --replace-fail "packaging = \"^23.0\"" "packaging = \"^24.0\""
      # --replace-fail "linkify-it-py~=1.0" "linkify-it-py" \
      # --replace-fail "markdown-it-py~=2.1.0" "markdown-it-py" \
  '';

  build-system = [hatchling];

  dependencies = [
    timg

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
    pillow
    sixelcrop
    universal-pathlib
    fsspec
    jupytext
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
    maintainers = with maintainers; [renesat];
  };
}
