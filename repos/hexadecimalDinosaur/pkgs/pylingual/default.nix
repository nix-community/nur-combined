{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pythonOlder,
  poetry-core,
  pythonRelaxDepsHook,
  asttokens,
  datasets,
  huggingface-hub,
  matplotlib,
  networkx,
  numpy,
  pydot,
  requests,
  tokenizers,
  torch,
  tqdm,
  rich,
  seqeval,
  transformers,
  xdis,
  click
}:

buildPythonPackage (finalAttrs: {
  pname = "pylingual";
  version = "0.1.0+unstable.2025.08.05";

  src = fetchFromGitHub {
    owner = "syssec-utd";
    repo = "pylingual";
    rev = "c47afd9791318628a475794a2c14db9f042475a8";
    hash = "sha256-XRIIaCv2WI4IU4ok4xU9RSzXwdcZ5HEfSkp03rztdE4=";
  };

  postPatch = ''
    substituteInPlace \
      pyproject.toml \
      --replace-fail 'version = "0.1.0"' 'version = "${finalAttrs.version}"'
  '';

  pyproject = true;
  build-system = [
    poetry-core
  ];
  disabled = pythonOlder "3.12";

  nativeBuildInputs = [
    pythonRelaxDepsHook
  ];

  dependencies = [
    asttokens
    datasets
    huggingface-hub
    matplotlib
    networkx
    numpy
    pydot
    requests
    tokenizers
    torch
    tqdm
    rich
    seqeval
    transformers
    xdis
    click
  ] ++ transformers.optional-dependencies.torch;

  pythonRelaxDeps = [
    "transformers"
    "xdis"
  ];

  pythonImportsCheck = [ "pylingual" ];

  meta = {
    description = "Python decompiler for modern Python versions.";
    homepage = "https://github.com/syssec-utd/pylingual";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
    mainProgram = "pylingual";
  };
})
