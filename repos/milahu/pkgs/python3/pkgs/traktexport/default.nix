{
  lib,
  python,
  fetchFromGitHub,
  buildPythonApplication,
  setuptools,
  wheel,
  ipython,
  backoff,
  click,
  logzero,
  pytrakt,
}:

buildPythonApplication rec {
  pname = "traktexport";
  version = "0.1.10";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "purarue";
    repo = "traktexport";
    rev = "v${version}";
    hash = "sha256-BxKwD9IFz/yEnkAzHr/6RCiEDvVhlroNZTI1I92aA44=";
  };

  # unpin deps
  postPatch = ''
    sed -i 's/pytrakt>=.*/pytrakt/; s/click>=.*/click/' setup.cfg
  '';

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    ipython
    backoff
    click
    logzero
    pytrakt
  ];

  pythonImportsCheck = [
    #"traktexport"
  ];

  meta = {
    description = "Export your movie/tv show ratings and history from trakt.tv";
    homepage = "https://github.com/purarue/traktexport";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "traktexport";
  };
}
