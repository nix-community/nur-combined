{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,

  ansi2html,
  arrow,
  flask,
  flask-restful,
  # nvidia-ml-py # ; python_version < "3"
  # nvidia-ml-py3 # ; python_version >= "3" and python_version < "3.6"
  pynvml, # ; python_version >= "3.6"
  pandas,
  psutil,
  requests,
  six,
  termcolor,
  tabulate,
}:

buildPythonPackage (finalAttrs: {
  pname = "nvgpu";
  version = "0.10.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rossumai";
    repo = "nvgpu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eCE/rxZVtjhdQwl9m/3mL6hU877P2QOOWXmxonoVD8g=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    ansi2html
    arrow
    flask
    flask-restful
    # nvidia-ml-py # ; python_version < "3"
    # nvidia-ml-py3 # ; python_version >= "3" and python_version < "3.6"
    pynvml # ; python_version >= "3.6"
    pandas
    psutil
    requests
    six
    termcolor
    tabulate
  ];

  pythonImportsCheck = [
    "nvgpu"
  ];

  meta = {
    description = "NVIDIA GPU tools - monitoring on CLI & web app with multiple agents";
    homepage = "https://github.com/rossumai/nvgpu";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
