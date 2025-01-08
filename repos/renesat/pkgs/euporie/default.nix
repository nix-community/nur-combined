{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  aenum,
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
  version = "2.8.4";
  format = "pyproject";

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "joouha";
    repo = "euporie";
    rev = "v${version}";
    hash = "sha256-49IotdE4o3UFmvoY1AWzISXk05kfclA1PtYjxr87hj4=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "\"timg~=1.1.6\"," "" \
      --replace-fail "aenum~=3.1,<=3.1.12" "aenum" \
      --replace-fail "platformdirs~=3.5" "platformdirs"
    #   --replace-fail "packaging = \"^23.0\"" "packaging = \"^24.0\""
      # --replace-fail "linkify-it-py~=1.0" "linkify-it-py" \
      # --replace-fail "markdown-it-py~=2.1.0" "markdown-it-py" \
  '';

  build-system = [hatchling];

  dependencies = [
    aenum
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
    # fsspec[http]>=2022.12.0",
    fsspec
    jupytext
  ];

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
