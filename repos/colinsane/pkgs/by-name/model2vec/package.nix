{
  fetchFromGitHub,
  gitUpdater,
  python3,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "model2vec";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "MinishLab";
    repo = "model2vec";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PLjyi9raR76lGjKYnvJKsUEbN4LHWQL5TjekB7EYwjA=";
  };

  nativeBuildInputs = [
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    python3.pkgs.setuptools
    python3.pkgs.setuptools-scm
  ];
  propagatedBuildInputs = [
    python3.pkgs.jinja2
    python3.pkgs.joblib
    python3.pkgs.numpy
    python3.pkgs.safetensors
    python3.pkgs.tokenizers
    python3.pkgs.tqdm
  ];

  nativeCheckInputs = [
    python3.pkgs.pythonImportsCheckHook
  ];

  doCheck = true;

  pythonImportsCheck = [ "model2vec" ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };
})
