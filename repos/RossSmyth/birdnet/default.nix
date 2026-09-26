{
  lib,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  soundfile,
  scipy,
  ordered-set,
  tqdm,
  numpy,
  pandas,
  psutil,
  pyarrow,
  kagglehub,
  tensorflowWithoutCuda,
  onnxruntime,
  ai-edge-litert,
  pytest-cov,
  pytest-xdist,
  pytest-timeout,
}:
buildPythonPackage (finalAttrs: {
  pname = "birdnet";
  version = "1.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "birdnet-team";
    repo = "birdnet";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FleTK8KMjN8ylGAe+wWz56C3dcuFVdT8ITXDP3LIHGs=";
  };

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
  ];

  dependencies = [
    soundfile
    scipy
    ordered-set
    tqdm
    numpy
    pandas
    psutil
    pyarrow
    kagglehub
    tensorflowWithoutCuda
    onnxruntime
    ai-edge-litert
  ];

  # Tries to download model weights during tests
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  checkInputs = [
    pytest-cov
    pytest-xdist
    pytest-timeout
  ];

  pythonImportsCheck = [
    "birdnet"
  ];

  meta = {
    homepage = "https://birdnet.cornell.edu/birdnet";
    downloadPage = "https://github.com/birdnet-team/birdnet/releases";
    changelog = "https://github.com/birdnet-team/birdnet/releases/tag/v${finalAttrs.version}";
    license = [
      lib.licenses.mit
    ];
    maintainers = [
      lib.maintainers.RossSmyth
    ];
  };
})
